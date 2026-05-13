# Milestone 1 — Hub VNet

## Create Resource Group
az group create --name hub-spoke-project --location eastus

## Create Hub VNet
az network vnet create --name hub-vnet --resource-group hub-spoke-project --address-prefix 10.1.0.0/16 --location eastus

## Create Subnets
az network vnet subnet create --resource-group hub-spoke-project --vnet-name hub-vnet --name AzureFirewallSubnet --address-prefixes 10.1.1.0/26
az network vnet subnet create --resource-group hub-spoke-project --vnet-name hub-vnet --name GatewaySubnet --address-prefixes 10.1.2.0/27
az network vnet subnet create --resource-group hub-spoke-project --vnet-name hub-vnet --name AzureBastionSubnet --address-prefixes 10.1.3.0/26
az network vnet subnet create --resource-group hub-spoke-project --vnet-name hub-vnet --name ManagementSubnet --address-prefixes 10.1.4.0/24
