# Project 4 Milestone 4 — NBA AI Container App

## Build and push image
az acr login --name nbadevopsregistry
docker buildx build --platform linux/amd64 -t nbadevopsregistry.azurecr.io/nba-ai-app:v2 --push .

## Deploy Container App
az containerapp create --name nba-ai-app --resource-group my-dev-ops-

cd ~/AzureProjects
mkdir -p Project1-NBA-Cloud-Analytics/app
cp ~/nba-ai-app/app.py Project1-NBA-Cloud-Analytics/app/
cp ~/nba-ai-app/Dockerfile Project1-NBA-Cloud-Analytics/app/
cp ~/nba-ai-app/requirements.txt Project1-NBA-Cloud-Analytics/app/

cat > Project1-NBA-Cloud-Analytics/commands/milestone-project4-m4.md << 'EOF'
# Project 4 Milestone 4 — NBA AI Container App

## Build and push image
az acr login --name nbadevopsregistry
docker buildx build --platform linux/amd64 -t nbadevopsregistry.azurecr.io/nba-ai-app:v2 --push .

## Deploy Container App
az containerapp create --name nba-ai-app --resource-group my-dev-ops-project --environment my-devops-app --image nbadevopsregistry.azurecr.io/nba-ai-app:v2 --registry-server nbadevopsregistry.azurecr.io --registry-username nbadevopsregistry --target-port 8080 --ingress external --min-replicas 1

## Live URL
https://nba-ai-app.livelyforest-fcdb9fb3.eastus.azurecontainerapps.io

## Test
curl -X POST https://nba-ai-app.livelyforest-fcdb9fb3.eastus.azurecontainerapps.io/ask -H "Content-Type: application/json" -d '{"question": "Who has the highest points per game?"}'
## Result: Joel Embiid - 34.7 PPG from NBA CSV data!
