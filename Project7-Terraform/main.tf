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

resource "azurerm_network_security_group" "nbastore_nsg" {
  name                = "nbastore-nsg"
  resource_group_name = azurerm_resource_group.nbastore.name
  location            = azurerm_resource_group.nbastore.location

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web_nsg" {
  subnet_id                 = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.nbastore_nsg.id
}

resource "azurerm_storage_account" "nbastore_storage" {
  name                     = "nbastoretf"
  resource_group_name      = azurerm_resource_group.nbastore.name
  location                 = azurerm_resource_group.nbastore.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_key_vault" "nbastore_kv" {
  name                       = "nbastore-kv"
  resource_group_name        = azurerm_resource_group.nbastore.name
  location                   = azurerm_resource_group.nbastore.location
  tenant_id                  = "05a1a49a-7628-4261-81d6-46cfc6810d34"
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = "05a1a49a-7628-4261-81d6-46cfc6810d34"
    object_id = "f1147f64-68a0-4e42-9ddf-a6aafdbdfec0"
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
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
