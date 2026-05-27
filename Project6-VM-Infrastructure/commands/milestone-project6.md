# Project 6 — NBA VM Infrastructure

## Milestone 1 - Networking
az group create --name nba-network --location eastus
az network vnet create --name NBA-VNET --resource-group nba-network --address-prefix 10.0.0.0/16 --subnet-name WebSubnet --subnet-prefix 10.0.1.0/24
az network vnet subnet create --name AzureBastionSubnet --resource-group nba-network --vnet-name NBA-VNET --address-prefix 10.0.2.0/24
az network nsg create --name nba-nsg --resource-group nba-network

## Milestone 2 - VMs
az vm availability-set create --name nba-availability-set --resource-group nba-network --platform-fault-domain-count 2 --platform-update-domain-count 5
az vm create --name nbasports-vm1 --resource-group nba-network --image Ubuntu2204 --size Standard_D2s_v3 --availability-set nba-availability-set --vnet-name NBA-VNET --subnet WebSubnet --public-ip-address "" --admin-username azureuser --generate-ssh-keys --no-wait
az vm create --name nbasports-vm2 --resource-group nba-network --image Ubuntu2204 --size Standard_D2s_v3 --availability-set nba-availability-set --vnet-name NBA-VNET --subnet WebSubnet --public-ip-address "" --admin-username azureuser --generate-ssh-keys --no-wait

## Milestone 3 - Load Balancer
az network public-ip create --name nba-lb-pip --resource-group nba-network --sku Standard --allocation-method Static
az network lb create --name nba-load-balancer --resource-group nba-network --sku Standard --public-ip-address nba-lb-pip --frontend-ip-name nba-frontend --backend-pool-name nba-backend-pool
az network lb probe create --name nba-health-probe --lb-name nba-load-balancer --resource-group nba-network --protocol Http --port 80 --path "/"
az network lb rule create --name nba-lb-rule --lb-name nba-load-balancer --resource-group nba-network --protocol Tcp --frontend-port 80 --backend-port 80 --frontend-ip-name nba-frontend --backend-pool-name nba-backend-pool --probe-name nba-health-probe

## Milestone 4 - Bastion
az network public-ip create --name nba-bastion-pip --resource-group nba-network --sku Standard --allocation-method Static
az network bastion create --name nba-bastion --resource-group nba-network --vnet-name NBA-VNET --public-ip-address nba-bastion-pip --sku Basic --no-wait

## Milestone 5 - Backup
az backup vault create --name nba-backup-vault --resource-group nba-network --location eastus
az backup protection enable-for-vm --resource-group nba-network --vault-name nba-backup-vault --vm nbasports-vm1 --policy-name DefaultPolicy
az backup protection enable-for-vm --resource-group nba-network --vault-name nba-backup-vault --vm nbasports-vm2 --policy-name DefaultPolicy

## Milestone 6 - Monitor
az monitor action-group create --name nba-action-group --resource-group nba-network --short-name nbaalerts --action email nba-admin Harveyr@roderickharvey10gmail.onmicrosoft.com
az monitor metrics alert create --name nba-cpu-alert --resource-group nba-network --scopes "/subscriptions/e6b4cc00-3c07-4595-8bb7-ca22d6ca16f5/resourceGroups/nba-network/providers/Microsoft.Compute/virtualMachines/nbasports-vm1" --condition "avg Percentage CPU > 80" --window-size 5m --evaluation-frequency 1m --action nba-action-group --severity 2

## Errors Learned
## Standard_B2s not available in eastus → use Standard_D2s_v3
## NIC IP config name is ipconfignbasports-vm1 not ipconfig1
## az backup protected-item → use az backup container list instead
