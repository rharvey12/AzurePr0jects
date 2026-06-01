// Bicep file - Project 10 walkthrough
// Compare this to Terraform!

targetScope = 'subscription'

@description('Resource group name')
param rgName string = 'bicep-demo-rg'

@description('Location for all resources')
param location string = 'East US'

// Create Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: location
  tags: {
    project: 'Project10-Bicep'
    deployedBy: 'Roderick'
  }
}

// Output the resource group ID
output rgId string = resourceGroup.id
output rgLocation string = resourceGroup.location
