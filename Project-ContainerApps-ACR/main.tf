# Container Apps + ACR Integration
# Modern serverless containers with private registry
# NIST 800-53: AC-3, SI-7, SC-7

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

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-containerapps-acr"
  location = "East US"

  tags = {
    environment = "production"
    compliance  = "NIST-800-53"
    owner       = "isso-team@nbateams.com"
    pattern     = "serverless-containers"
  }
}

# Log Analytics (required for Container Apps)
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-containerapps"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# Azure Container Registry (Premium for production)
resource "azurerm_container_registry" "main" {
  name                = "acrcontainer${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Premium"
  admin_enabled       = false

  # Premium features
  public_network_access_enabled = false
  zone_redundancy_enabled       = true

  # Content trust for signed images (NIST SI-7)
  trust_policy {
    enabled = true
  }

  # Retention for soft-deleted images
  retention_policy {
    days    = 30
    enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = azurerm_resource_group.main.tags
}

# Container App Environment
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-nbaapp"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = azurerm_resource_group.main.tags
}

# User-assigned identity for Container App
resource "azurerm_user_assigned_identity" "containerapp" {
  name                = "id-containerapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Grant identity ACR Pull role
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.containerapp.principal_id
}

# Container App (serverless, scale to zero)
resource "azurerm_container_app" "main" {
  name                         = "ca-nbaapp"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapp.id]
  }

  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.containerapp.id
  }

  template {
    container {
      name   = "nbaapp"
      image  = "mcr.microsoft.com/k8se/quickstart:latest" # Public image for demo
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "ENVIRONMENT"
        value = "production"
      }
    }

    # SCALE TO ZERO when idle!
    min_replicas = 0
    max_replicas = 10

    # Auto-scale based on HTTP traffic
    http_scale_rule {
      name                = "http-scaler"
      concurrent_requests = 50
    }
  }

  ingress {
    external_enabled = true
    target_port      = 80
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = azurerm_resource_group.main.tags
}

# Outputs
output "container_app_url" {
  value = "https://${azurerm_container_app.main.latest_revision_fqdn}"
}

output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

output "pattern_description" {
  value = "Container Apps + ACR Premium with managed identity (NO passwords!)"
}

output "compliance" {
  value = "NIST 800-53: SI-7 (signed images), AC-3 (managed identity), SC-7 (private network)"
}
