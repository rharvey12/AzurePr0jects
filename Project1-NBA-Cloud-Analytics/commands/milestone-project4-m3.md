# Project 4 Milestone 3 — RAG Configuration

## Recreate AI Search
az search service create --name nba-ai-search --resource-group my-dev-ops-project --sku basic --location eastus

## Get admin key and store in Key Vault
az search admin-key show --service-name nba-ai-search --resource-group my-dev-ops-project --query "primaryKey" --output tsv

## Index created via Portal - RAG wizard
## Index name: rag-1779756830276 (auto-generated)
## Data source: nbastatstorage/player-data
## Embedding: nba-openai/nba-embedding

## Test RAG
python3 ~/test_rag2.py
## Result: "Joel Embiid has the highest points per game with 34.7"
## Confirmed RAG using NBA CSV data not general knowledge!
