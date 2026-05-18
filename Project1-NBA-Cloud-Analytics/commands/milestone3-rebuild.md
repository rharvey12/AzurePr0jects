# Milestone 3 Rebuild — VNet + Private Endpoints + DNS Zones
az network vnet create --name myvnet --resource-group my-dev-ops-project --address-prefix 10.0.0.0/16 --location eastus
az network vnet subnet create --resource-group my-dev-ops-project --vnet-name myvnet --name PublicSubnet --address-prefixes 10.0.2.0/24
az network vnet subnet create --resource-group my-dev-ops-project --vnet-name myvnet --name PrivateSubnet --address-prefixes 10.0.3.0/24

# Private Endpoints
az network private-endpoint create --name Endpoint2 --resource-group my-dev-ops-project --vnet-name myvnet --subnet PrivateSubnet --private-connection-resource-id $(az storage account show --name nbastatstorage --resource-group my-dev-ops-project --query id --output tsv) --group-id blob --connection-name MyConnection
az network private-endpoint create --name MyKeyVaultEndpoint --resource-group my-dev-ops-project --vnet-name myvnet --subnet PrivateSubnet --private-connection-resource-id $(az keyvault show --name nba-nbc-key --resource-group my-dev-ops-project --query id --output tsv) --group-id vault --connection-name MyKVConnection

# Private DNS Zones
az network private-dns zone create --resource-group my-dev-ops-project --name "privatelink.blob.core.windows.net"
az network private-dns link vnet create --resource-group my-dev-ops-project --zone-name "privatelink.blob.core.windows.net" --name "BlobDNSLink" --virtual-network myvnet --registration-enabled false
az network private-dns zone create --resource-group my-dev-ops-project --name "privatelink.vaultcore.azure.net"
az network private-dns link vnet create --resource-group my-dev-ops-project --zone-name "privatelink.vaultcore.azure.net" --name "KeyVaultDNSLink" --virtual-network myvnet --registration-enabled false
