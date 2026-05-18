# Milestone 2 Rebuild — Key Vault
az keyvault create --name nba-nbc-key --resource-group my-dev-ops-project --location eastus
az keyvault secret set --vault-name nba-nbc-key --name "nba-api-key" --value "fake-nba-api-key-123"
az keyvault secret set --vault-name nba-nbc-key --name "storage-connection-string" --value "fake-storage-connection-123"
az keyvault secret set --vault-name nba-nbc-key --name "scoring-algorithm-key" --value "fake-scoring-key-123"
