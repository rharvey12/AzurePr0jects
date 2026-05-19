# Project 3 Rebuild — Complete Commands

## Hub VNet
az network vnet create --name hub-vnet --resource-group hub-spoke-project --address-prefix 10.1.0.0/16 --location eastus
az network vnet subnet create --resource-group hub-spoke-project --vnet-name hub-vnet --name AzureFirewallSubnet --address-prefixes 10.1.1.0/26
az network vnet subnet create --resource-group hub-spoke-project --vnet-name hub-vnet --name GatewaySubnet --address-prefixes 10.1.2.0/27
az network vnet subnet create --resource-group hub-spoke-project --vnet-name hub-vnet --name AzureBastionSubnet --address-prefixes 10.1.3.0/26
az network vnet subnet create --resource-group hub-spoke-project --vnet-name hub-vnet --name ManagementSubnet --address-prefixes 10.1.4.0/24

## Spoke VNets
az network vnet create --name Spoke1VNet --resource-group hub-spoke-project --address-prefix 10.2.0.0/16 --location eastus
az network vnet subnet create --resource-group hub-spoke-project --vnet-name Spoke1VNet --name ProductionSubnet --address-prefixes 10.2.1.0/25
az network vnet create --name Spoke2VNet --resource-group hub-spoke-project --address-prefix 10.3.0.0/16 --location eastus
az network vnet subnet create --resource-group hub-spoke-project --vnet-name Spoke2VNet --name DevelopmentSubnet --address-prefixes 10.3.1.0/25

## VNet Peering
az network vnet peering create --name hub-to-spoke1 --resource-group hub-spoke-project --vnet-name hub-vnet --remote-vnet $(az network vnet show --name Spoke1VNet --resource-group hub-spoke-project --query id --output tsv) --allow-vnet-access
az network vnet peering create --name spoke1-to-hub --resource-group hub-spoke-project --vnet-name Spoke1VNet --remote-vnet $(az network vnet show --name hub-vnet --resource-group hub-spoke-project --query id --output tsv) --allow-vnet-access
az network vnet peering create --name hub-to-spoke2 --resource-group hub-spoke-project --vnet-name hub-vnet --remote-vnet $(az network vnet show --name Spoke2VNet --resource-group hub-spoke-project --query id --output tsv) --allow-vnet-access
az network vnet peering create --name spoke2-to-hub --resource-group hub-spoke-project --vnet-name Spoke2VNet --remote-vnet $(az network vnet show --name hub-vnet --resource-group hub-spoke-project --query id --output tsv) --allow-vnet-access

## Route Tables (deploy Firewall first via Portal)
az network route-table create --name spoke1-route-table --resource-group hub-spoke-project --location eastus
az network route-table create --name spoke2-route-table --resource-group hub-spoke-project --location eastus
az network route-table route create --name to-firewall --route-table-name spoke1-route-table --resource-group hub-spoke-project --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.1.1.4
az network route-table route create --name to-firewall --route-table-name spoke2-route-table --resource-group hub-spoke-project --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.1.1.4
az network vnet subnet update --name ProductionSubnet --vnet-name Spoke1VNet --resource-group hub-spoke-project --route-table spoke1-route-table
az network vnet subnet update --name DevelopmentSubnet --vnet-name Spoke2VNet --resource-group hub-spoke-project --route-table spoke2-route-table
