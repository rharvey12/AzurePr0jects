# Milestone 4 Rebuild — Container App + Managed Identity
az acr create --resource-group my-dev-ops-project --name nbadevopsregistry --sku Basic
az acr update -n nbadevopsregistry --admin-enabled true
az containerapp create --name nba-stats-app --resource-group my-dev-ops-project --environment my-devops-app --image nbadevopsregistry.azurecr.io/azure-app:v1 --registry-server nbadevopsregistry.azurecr.io --registry-username nbadevopsregistry --target-port 8080 --ingress external --min-replicas 1
az containerapp identity assign --name nba-stats-app --resource-group my-dev-ops-project --system-assigned
az role assignment create --role "Key Vault Secrets User" --assignee $(az containerapp identity show --name nba-stats-app --resource-group my-dev-ops-project --query principalId --output tsv) --scope $(az keyvault show --name nba-nbc-key --resource-group my-dev-ops-project --query id --output tsv)
az role assignment create --role "Storage Blob Data Reader" --assignee $(az containerapp identity show --name nba-stats-app --resource-group my-dev-ops-project --query principalId --output tsv) --scope $(az storage account show --name nbastatstorage --resource-group my-dev-ops-project --query id --output tsv)
