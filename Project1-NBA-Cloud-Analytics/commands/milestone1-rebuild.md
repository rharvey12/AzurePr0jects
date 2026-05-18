# Milestone 1 Rebuild — Blob Storage
az storage account create --name nbastatstorage --resource-group my-dev-ops-project --location eastus --sku Standard_RAGRS
az storage container create --name player-data --account-name nbastatstorage
az storage container create --name game-stats --account-name nbastatstorage
az storage container create --name team-rosters --account-name nbastatstorage
