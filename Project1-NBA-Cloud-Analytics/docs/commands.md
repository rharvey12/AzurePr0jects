az storage account create --name nbastatstorageus --resource-group my-dev-ops-project --location eastus --sku Standard_RAGRS
az keyvault create --name NBC --resource-group my-dev-ops-project --location eastus

az network private-endpoint create --name EndPoint1 --resource-group my-dev-ops-project --vnet-name my-vnet --subnet PrivateSubnet --group-id blob
az containerapp create --name my-devops-app --resource-group my-dev-ops-project --environment my-devops-env
