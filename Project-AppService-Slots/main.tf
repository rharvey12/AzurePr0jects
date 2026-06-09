# App Service with Deployment Slots
# Blue/green deployment pattern
# NIST 800-53 SI-7 (Software Integrity)

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
  name     = "rg-appservice-slots"
  location = "East US"

  tags = {
    environment = "production"
    compliance  = "NIST-800-53"
    owner       = "isso-team@nbateams.com"
    pattern     = "blue-green-deployment"
  }
}

# Log Analytics for monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-appservice"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# Application Insights for APM
resource "azurerm_application_insights" "main" {
  name                = "appi-nba-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
}

# App Service Plan (Standard - supports slots)
resource "azurerm_service_plan" "main" {
  name                = "asp-nba-app"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "S1" # Standard tier supports slots

  tags = azurerm_resource_group.main.tags
}

# PRIMARY (Production) App Service
resource "azurerm_linux_web_app" "main" {
  name                = "nba-app-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.main.id

  https_only = true

  site_config {
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
    http2_enabled       = true

    application_stack {
      docker_image_name   = "nginx:alpine" # Example
      docker_registry_url = "https://mcr.microsoft.com"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    "ENVIRONMENT"                           = "production"
  }

  tags = azurerm_resource_group.main.tags
}

# STAGING SLOT (Blue/Green deployment)
resource "azurerm_linux_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_linux_web_app.main.id

  https_only = true

  site_config {
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
    http2_enabled       = true

    application_stack {
      docker_image_name   = "nginx:alpine"
      docker_registry_url = "https://mcr.microsoft.com"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.main.connection_string
    "ENVIRONMENT"                           = "staging"
  }

  tags = merge(azurerm_resource_group.main.tags, {
    slot_type = "staging"
  })
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "main" {
  name                       = "appservice-to-law"
  target_resource_id         = azurerm_linux_web_app.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Outputs
output "production_url" {
  value = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "staging_url" {
  value = "https://${azurerm_linux_web_app_slot.staging.default_hostname}"
}

output "deployment_pattern" {
  value = "Deploy → Test in staging → Swap to production = zero downtime"
}

output "compliance_alignment" {
  value = "NIST 800-53: SI-7 (Software Integrity), CM-3 (Change Control)"
}
