# Milestone 6 — Route Tables

## Create Route Tables
az network route-table create --name spoke1-route-table --resource-group hub-spoke-project --location eastus
az network route-table create --name spoke2-route-table --resource-group hub-spoke-project --location eastus

## Add Routes to Firewall (10.1.1.4)
az network route-table route create --name to-firewall --route-table-name spoke1-route-table --resource-group hub-spoke-project --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.1.1.4
az network route-table route create --name to-firewall --route-table-name spoke2-route-table --resource-group hub-spoke-project --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.1.1.4

## Attach to Spoke Subnets
az network vnet subnet update --name ProductionSubnet --vnet-name SpokeVNet1 --resource-group hub-spoke-project --route-table spoke1-route-table
az network vnet subnet update --name DevelopmentSubnet --vnet-name SpokeVNet2 --resource-group hub-spoke-project --route-table spoke2-route-table
