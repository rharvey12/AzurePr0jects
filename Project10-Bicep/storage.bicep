// Storage Account in Bicep
// Compare to Terraform's azurerm_storage_account

@description('Storage account name (must be unique)')
param storageName string = 'bicep${uniqueString(resourceGroup().id)}'

@description('Location for storage')
param location string = resourceGroup().location

// Storage Account resource
resource storage 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
  }
  tags: {
    project: 'Project10-Bicep'
  }
}

output storageId string = storage.id
output storageName string = storage.name
