# PIM + Sentinel Security Architecture
# Real enterprise pattern for privileged access monitoring

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "subscription_id" {
  type = string
}

# ============================================
# RESOURCE GROUP for security tooling
# ============================================
resource "azurerm_resource_group" "security" {
  name     = "rg-security-monitoring"
  location = "East US"
  
  tags = {
    purpose     = "security-monitoring"
    compliance  = "NIST-800-53"
    owner       = "isso-team@nbateams.com"
    environment = "production"
  }
}

# ============================================
# LOG ANALYTICS WORKSPACE (security data lake)
# ============================================
resource "azurerm_log_analytics_workspace" "security" {
  name                = "law-security-monitoring"
  location            = azurerm_resource_group.security.location
  resource_group_name = azurerm_resource_group.security.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  
  tags = {
    purpose = "siem-data-lake"
    nist    = "AU-2, AU-4, AU-6"
  }
}

# ============================================
# SENTINEL onboarding
# ============================================
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  workspace_id                 = azurerm_log_analytics_workspace.security.id
  customer_managed_key_enabled = false
}

# ============================================
# DIAGNOSTIC SETTINGS - Send Entra ID logs
# ============================================
resource "azurerm_monitor_aad_diagnostic_setting" "entra_to_sentinel" {
  name                       = "entra-logs-to-sentinel"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.security.id

  enabled_log {
    category = "AuditLogs"  # PIM events here!
  }

  enabled_log {
    category = "SignInLogs"
  }

  enabled_log {
    category = "RiskyUsers"
  }

  enabled_log {
    category = "UserRiskEvents"
  }
}

# ============================================
# ACTION GROUP for alerts
# ============================================
resource "azurerm_monitor_action_group" "security_alerts" {
  name                = "ag-security-incidents"
  resource_group_name = azurerm_resource_group.security.name
  short_name          = "SecAlerts"

  email_receiver {
    name          = "isso-team"
    email_address = "isso-team@nbateams.com"
  }
}

# ============================================
# OUTPUTS
# ============================================
output "workspace_id" {
  value = azurerm_log_analytics_workspace.security.id
}

output "workspace_customer_id" {
  value = azurerm_log_analytics_workspace.security.workspace_id
}

output "sentinel_status" {
  value = "Sentinel enabled on workspace"
}
