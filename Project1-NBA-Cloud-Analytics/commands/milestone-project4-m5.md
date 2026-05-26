# Project 4 Milestone 5 — Security & RBAC

## Assign Managed Identity
az containerapp identity assign --name nba-ai-app --resource-group my-dev-ops-project --system-assigned

## RBAC Roles
az role assignment create --role "Key Vault Secrets User" --assignee b97dce5a-4218-456c-94bd-609ed3537e1f --scope $(az keyvault show --name nba-nbc-key --resource-group my-dev-ops-project --query id --output tsv)
az role assignment create --role "Storage Blob Data Reader" --assignee b97dce5a-4218-456c-94bd-609ed3537e1f --scope $(az storage account show --name nbastatstorage --resource-group my-dev-ops-project --query id --output tsv)
az role assignment create --role "Search Index Data Reader" --assignee b97dce5a-4218-456c-94bd-609ed3537e1f --scope $(az search service show --name nba-ai-search --resource-group my-dev-ops-project --query id --output tsv)
