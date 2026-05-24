# Project 4 Milestone 1 — Azure OpenAI Setup

## Register Provider
az provider register --namespace Microsoft.CognitiveServices --wait

## Create Azure OpenAI Resource
az cognitiveservices account create --name nba-openai --resource-group my-dev-ops-project --location eastus --kind OpenAI --sku s0 --yes

## Deploy Chat Model
az cognitiveservices account deployment create --name nba-openai --resource-group my-dev-ops-project --deployment-name nba-gpt4-mini --model-name gpt-4.1-mini --model-version "2025-04-14" --model-format OpenAI --sku-capacity 10 --sku-name "Standard"

## Deploy Embedding Model
az cognitiveservices account deployment create --name nba-openai --resource-group my-dev-ops-project --deployment-name nba-embedding --model-name text-embedding-3-small --model-version "1" --model-format OpenAI --sku-capacity 10 --sku-name "Standard"

## Store API Key in Key Vault
az keyvault secret set --vault-name nba-nbc-key --name "openai-api-key" --value "YOUR_KEY"
