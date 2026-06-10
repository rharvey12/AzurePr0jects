# NBA Analytics Platform - Foundation
# Integration project tying together all enterprise patterns
# NIST 800-53 aligned

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ============================================
# VARIABLES
# ============================================
variable "environment" {
  type        = string
  default     = "production"
  description = "Deployment environment"
}

variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

# ============================================
# RESOURCE GROUPS (separation of concerns)
# ============================================
resource "azurerm_resource_group" "platform" {
  name     = "rg-nba-platform"
  location = var.location

  tags = {
    environment = var.environment
    project     = "nba-analytics"
    compliance  = "NIST-800-53"
    owner       = "isso-team@nbateams.com"
  }
}

resource "azurerm_resource_group" "data" {
  name     = "rg-nba-data"
  location = var.location

  tags = merge(azurerm_resource_group.platform.tags, {
    purpose = "data-tier"
  })
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-nba-monitoring"
  location = var.location

  tags = merge(azurerm_resource_group.platform.tags, {
    purpose = "observability"
  })
}

# ============================================
# CENTRAL LOG ANALYTICS WORKSPACE
# All services log here for unified observability
# ============================================
resource "azurerm_log_analytics_workspace" "central" {
  name                = "law-nba-central"
  location            = var.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = 90

  tags = azurerm_resource_group.monitoring.tags
}

# Sentinel onboarding
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  workspace_id = azurerm_log_analytics_workspace.central.id
}

# ============================================
# KEY VAULT (centralized secrets management)
# All apps reference secrets here, never hardcode
# ============================================
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "kv-nba${random_string.suffix.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.platform.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enabled_for_disk_encryption     = true
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90

  enable_rbac_authorization     = true  # Modern RBAC vs access policies
  public_network_access_enabled = false # Private endpoint required

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = azurerm_resource_group.platform.tags
}

# ============================================
# HUB VNET (shared services)
# ============================================
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-nba-hub"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.platform.name

  tags = azurerm_resource_group.platform.tags
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/26"]
}

resource "azurerm_subnet" "shared_services" {
  name                 = "snet-shared-services"
  resource_group_name  = azurerm_resource_group.platform.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

# ============================================
# DATA VNET (private - storage tier)
# ============================================
resource "azurerm_virtual_network" "data" {
  name                = "vnet-nba-data"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.data.name

  tags = azurerm_resource_group.data.tags
}

resource "azurerm_subnet" "data_storage" {
  name                 = "snet-data-storage"
  resource_group_name  = azurerm_resource_group.data.name
  virtual_network_name = azurerm_virtual_network.data.name
  address_prefixes     = ["10.1.1.0/24"]

  service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
}

# ============================================
# VNET PEERING (Hub-Spoke pattern)
# ============================================
resource "azurerm_virtual_network_peering" "hub_to_data" {
  name                         = "peer-hub-to-data"
  resource_group_name          = azurerm_resource_group.platform.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.data.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "data_to_hub" {
  name                         = "peer-data-to-hub"
  resource_group_name          = azurerm_resource_group.data.name
  virtual_network_name         = azurerm_virtual_network.data.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
}

# ============================================
# OUTPUTS (for downstream modules)
# ============================================
output "platform_rg_id" {
  value = azurerm_resource_group.platform.id
}

output "data_rg_id" {
  value = azurerm_resource_group.data.id
}

output "monitoring_rg_id" {
  value = azurerm_resource_group.monitoring.id
}

output "central_workspace_id" {
  value = azurerm_log_analytics_workspace.central.id
}

output "key_vault_id" {
  value = azurerm_key_vault.main.id
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "data_vnet_id" {
  value = azurerm_virtual_network.data.id
}

output "architecture_summary" {
  value = "NBA Platform foundation: 3 RGs, Hub-Spoke VNets, Central LAW, Sentinel, Key Vault"
}
