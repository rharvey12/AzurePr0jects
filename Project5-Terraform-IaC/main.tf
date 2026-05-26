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
