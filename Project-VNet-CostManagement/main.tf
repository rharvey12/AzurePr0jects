# VNet + Subnets + Cost Management
# Production-ready networking with cost controls

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

# ============================================
# RESOURCE GROUP with tags
# ============================================
resource "azurerm_resource_group" "vnet" {
  name     = "rg-vnet-production"
  location = "East US"
  
  tags = {
    department  = "engineering"
    costcenter  = "CC-12345"
    environment = "production"
    owner       = "isso-team@nbateams.com"
    compliance  = "NIST-800-53"
  }
}

# ============================================
# VIRTUAL NETWORK
# ============================================
resource "azurerm_virtual_network" "main" {
  name                = "vnet-production"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vnet.location
  resource_group_name = azurerm_resource_group.vnet.name
  
  tags = azurerm_resource_group.vnet.tags
}

# ============================================
# SUBNETS (multi-tier pattern)
# ============================================
resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "data-subnet"
  resource_group_name  = azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.vnet.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.4.0/26"]
}

# ============================================
# COST MANAGEMENT
# ============================================
resource "azurerm_monitor_action_group" "cost_alerts" {
  name                = "ag-cost-alerts"
  resource_group_name = azurerm_resource_group.vnet.name
  short_name          = "CostAlerts"

  email_receiver {
    name          = "isso-team"
    email_address = "isso-team@nbateams.com"
  }

  email_receiver {
    name          = "finance"
    email_address = "finance@nbateams.com"
  }
}

resource "azurerm_consumption_budget_resource_group" "monthly" {
  name              = "vnet-rg-monthly-budget"
  resource_group_id = azurerm_resource_group.vnet.id

  amount     = 200
  time_grain = "Monthly"

  time_period {
    start_date = "2026-07-01T00:00:00Z"
    end_date   = "2027-07-01T00:00:00Z"
  }

  # 50% Early Warning
  notification {
    enabled        = true
    threshold      = 50.0
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = ["isso-team@nbateams.com"]
    contact_groups = [azurerm_monitor_action_group.cost_alerts.id]
  }

  # 80% Urgent
  notification {
    enabled        = true
    threshold      = 80.0
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = ["isso-team@nbateams.com", "manager@nbateams.com"]
    contact_groups = [azurerm_monitor_action_group.cost_alerts.id]
  }

  # 100% Forecasted (predictive)
  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = ["finance@nbateams.com", "isso-team@nbateams.com"]
    contact_groups = [azurerm_monitor_action_group.cost_alerts.id]
  }
}

# ============================================
# OUTPUTS
# ============================================
output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "budget_amount" {
  value = "$${azurerm_consumption_budget_resource_group.monthly.amount}/month"
}
