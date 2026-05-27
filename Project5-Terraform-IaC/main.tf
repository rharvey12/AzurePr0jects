resource "azurerm_resource_group" "nba_rg" {
  name     = "nba-terraform-project"
  location = "East US"
}

resource "azurerm_storage_account" "nba_storage" {
  name                     = "nbaterraformstorage"
  resource_group_name      = azurerm_resource_group.nba_rg.name
  location                 = azurerm_resource_group.nba_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "player_data" {
  name                  = "player-data"
  storage_account_name  = azurerm_storage_account.nba_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "game_stats" {
  name                  = "game-stats"
  storage_account_name  = azurerm_storage_account.nba_storage.name
  container_access_type = "private"
}

resource "azurerm_key_vault" "nba_kv" {
  name                        = "nba-terraform-kv"
  location                    = azurerm_resource_group.nba_rg.location
  resource_group_name         = azurerm_resource_group.nba_rg.name
  tenant_id                   = "05a1a49a-7628-4261-81d6-46cfc6810d34"
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  access_policy {
    tenant_id = "05a1a49a-7628-4261-81d6-46cfc6810d34"
    object_id = "f1147f64-68a0-4e42-9ddf-a6aafdbdfec0"

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
  }
}

resource "azurerm_virtual_network" "nba_vnet" {
  name                = "nba-terraform-vnet"
  location            = azurerm_resource_group.nba_rg.location
  resource_group_name = azurerm_resource_group.nba_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "PublicSubnet"
  resource_group_name  = azurerm_resource_group.nba_rg.name
  virtual_network_name = azurerm_virtual_network.nba_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "PrivateSubnet"
  resource_group_name  = azurerm_resource_group.nba_rg.name
  virtual_network_name = azurerm_virtual_network.nba_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}
