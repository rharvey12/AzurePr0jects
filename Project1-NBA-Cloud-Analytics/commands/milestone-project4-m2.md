# Project 4 Milestone 2 — Azure AI Search

## Create AI Search Resource
az search service create --name nba-ai-search --resource-group my-dev-ops-project --sku basic --location eastus

## Get Admin Key
az search admin-key show --service-name nba-ai-search --resource-group my-dev-ops-project --query "primaryKey" --output tsv

## Store Key in Key Vault
az keyvault secret set --vault-name nba-nbc-key --name "ai-search-key" --value "YOUR_KEY"

## Index created via Portal RAG wizard
## IMPORTANT: Index name is AUTO-GENERATED
## Actual name: rag-1779756830276
## Always verify with:
## curl GET https://nba-ai-search.search.windows.net/indexes?api-version=2023-11-01

## Verify data in index
## curl -X POST https://nba-ai-search.search.windows.net/indexes/rag-1779756830276/docs/search?api-version=2023-11-01
## -H "api-key: YOUR_KEY" -d '{"search": "*", "top": 5, "select": "chunk"}'
