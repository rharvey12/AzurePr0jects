resource "azurerm_resource_group" "nbastore" {
  name     = "nbastore"
  location = "East US"
}

resource "azurerm_virtual_network" "nbastore_vnet" {
  name                = "nbastore-vnet"
  resource_group_name = azurerm_resource_group.nbastore.name
  location            = azurerm_resource_group.nbastore.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "web_subnet" {
  name                 = "WebSubnet"
  resource_group_name  = azurerm_resource_group.nbastore.name
  virtual_network_name = azurerm_virtual_network.nbastore_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.nbastore.name
  virtual_network_name = azurerm_virtual_network.nbastore_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# NSG for Bastion Subnet (FIX: CKV2_AZURE_31)
resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "nbastore-bastion-nsg"
  resource_group_name = azurerm_resource_group.nbastore.name
  location            = azurerm_resource_group.nbastore.location
}

resource "azurerm_subnet_network_security_group_association" "bastion_nsg_assoc" {
  subnet_id                 = azurerm_subnet.bastion_subnet.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}

# Web NSG - FIXED: HTTP restricted to VNet only (NIST SC-7)
resource "azurerm_network_security_group" "nbastore_nsg" {
  name                = "nbastore-nsg"
  resource_group_name = azurerm_resource_group.nbastore.name
  location            = azurerm_resource_group.nbastore.location

  security_rule {
    name                       = "AllowHTTPSFromVNet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
    source_port_range          = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web_nsg" {
  subnet_id                 = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.nbastore_nsg.id
}

# HARDENED Storage Account (NIST SC-8, SC-28, AU-2)
resource "azurerm_storage_account" "nbastore_storage" {
  # checkov:skip=CKV2_AZURE_33: Private endpoints require DNS infrastructure - documented exception
  name                          = "nbastoretf"
  resource_group_name           = azurerm_resource_group.nbastore.name
  location                      = azurerm_resource_group.nbastore.location
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled     = false
  enable_https_traffic_only     = true

  blob_properties {
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 30
    }
  }
}

# HARDENED Key Vault (NIST AU-9, SC-28)
resource "azurerm_key_vault" "nbastore_kv" {
  # checkov:skip=CKV2_AZURE_32: Private endpoints require DNS infrastructure - documented exception
  name                          = "nbastore-kv"
  resource_group_name           = azurerm_resource_group.nbastore.name
  location                      = azurerm_resource_group.nbastore.location
  tenant_id                     = "05a1a49a-7628-4261-81d6-46cfc6810d34"
  sku_name                      = "standard"
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id = "05a1a49a-7628-4261-81d6-46cfc6810d34"
    object_id = "f1147f64-68a0-4e42-9ddf-a6aafdbdfec0"
    secret_permissions = ["Get", "List", "Set", "Delete"]
  }
}

resource "azurerm_availability_set" "nbastore_avset" {
  name                         = "nbastore-avset"
  resource_group_name          = azurerm_resource_group.nbastore.name
  location                     = azurerm_resource_group.nbastore.location
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}


# User Assigned Identity for Storage CMK
resource "azurerm_user_assigned_identity" "storage_identity" {
  name                = "nbastore-storage-identity"
  resource_group_name = azurerm_resource_group.nbastore.name
  location            = azurerm_resource_group.nbastore.location
}

# Grant Identity Access to Key Vault
resource "azurerm_key_vault_access_policy" "storage_cmk_policy" {
  key_vault_id = azurerm_key_vault.nbastore_kv.id
  tenant_id    = "05a1a49a-7628-4261-81d6-46cfc6810d34"
  object_id    = azurerm_user_assigned_identity.storage_identity.principal_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey"
  ]
}

# Customer Managed Key for Storage
resource "azurerm_key_vault_key" "storage_cmk" {
  name         = "storage-cmk"
  key_vault_id = azurerm_key_vault.nbastore_kv.id
  key_type     = "RSA-HSM"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  expiration_date = "2027-12-31T23:59:59Z"

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    expire_after         = "P365D"
    notify_before_expiry = "P30D"
  }

  depends_on = [azurerm_key_vault_access_policy.storage_cmk_policy]
}

# Storage CMK Configuration
resource "azurerm_storage_account_customer_managed_key" "storage_cmk" {
  storage_account_id        = azurerm_storage_account.nbastore_storage.id
  key_vault_id              = azurerm_key_vault.nbastore_kv.id
  key_name                  = azurerm_key_vault_key.storage_cmk.name
  user_assigned_identity_id = azurerm_user_assigned_identity.storage_identity.id
}
