# Milestone 3 — VNet Peering

## Hub to Spoke1
az network vnet peering create --name hub-to-spoke1 --resource-group hub-spoke-project --vnet-name hub-vnet --remote-vnet /subscriptions/e6b4cc00-3c07-4595-8bb7-ca22d6ca16f5/resourceGroups/hub-spoke-project/providers/Microsoft.Network/virtualNetworks/SpokeVNet1 --allow-vnet-access

## Spoke1 to Hub
az network vnet peering create --name spoke1-to-hub --resource-group hub-spoke-project --vnet-name SpokeVNet1 --remote-vnet /subscriptions/e6b4cc00-3c07-4595-8bb7-ca22d6ca16f5/resourceGroups/hub-spoke-project/providers/Microsoft.Network/virtualNetworks/hub-vnet --allow-vnet-access

## Hub to Spoke2
az network vnet peering create --name hub-to-spoke2 --resource-group hub-spoke-project --vnet-name hub-vnet --remote-vnet /subscriptions/e6b4cc00-3c07-4595-8bb7-ca22d6ca16f5/resourceGroups/hub-spoke-project/providers/Microsoft.Network/virtualNetworks/SpokeVNet2 --allow-vnet-access

## Spoke2 to Hub
az network vnet peering create --name spoke2-to-hub --resource-group hub-spoke-project --vnet-name SpokeVNet2 --remote-vnet /subscriptions/e6b4cc00-3c07-4595-8bb7-ca22d6ca16f5/resourceGroups/hub-spoke-project/providers/Microsoft.Network/virtualNetworks/hub-vnet --allow-vnet-access
