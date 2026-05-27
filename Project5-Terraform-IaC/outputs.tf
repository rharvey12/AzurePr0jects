output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.nba_rg.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.nba_storage.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.nba_kv.vault_uri
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.nba_vnet.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = azurerm_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.private_subnet.id
}
