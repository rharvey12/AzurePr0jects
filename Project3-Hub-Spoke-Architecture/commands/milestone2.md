# Milestone 2 — Spoke VNets

## Create Spoke 1 VNet
az network vnet create --name SpokeVNet1 --resource-group hub-spoke-project --address-prefix 10.2.0.0/16 --location eastus

## Create ProductionSubnet
az network vnet subnet create --resource-group hub-spoke-project --vnet-name SpokeVNet1 --name ProductionSubnet --address-prefixes 10.2.1.0/25

## Create Spoke 2 VNet
az network vnet create --name SpokeVNet2 --resource-group hub-spoke-project --address-prefix 10.3.0.0/16 --location eastus

## Create DevelopmentSubnet
az network vnet subnet create --resource-group hub-spoke-project --vnet-name SpokeVNet2 --name DevelopmentSubnet --address-prefixes 10.3.1.0/25
