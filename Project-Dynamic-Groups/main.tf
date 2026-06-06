# Dynamic Groups via Terraform
# Real enterprise IaC pattern for identity management

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azuread" {}
provider "azurerm" {
  features {}
}

# ============================================
# DYNAMIC GROUPS (require Entra ID P1)
# ============================================

resource "azuread_group" "engineering" {
  display_name     = "NBA-Engineering"
  description      = "Auto-managed engineering team"
  security_enabled = true
  mail_enabled     = false
  types            = ["DynamicMembership"]
  
  dynamic_membership {
    enabled = true
    rule    = "user.department -eq \"Engineering\""
  }
}

resource "azuread_group" "finance" {
  display_name     = "NBA-Finance"
  description      = "Auto-managed finance team"
  security_enabled = true
  mail_enabled     = false
  types            = ["DynamicMembership"]
  
  dynamic_membership {
    enabled = true
    rule    = "user.department -eq \"Finance\""
  }
}

# ============================================
# RESOURCE GROUPS (one per dept)
# ============================================

resource "azurerm_resource_group" "eng_rg" {
  name     = "rg-engineering-prod"
  location = "East US"
  
  tags = {
    department = "engineering"
    owner      = "eng-lead@nbateams.com"
  }
}

resource "azurerm_resource_group" "finance_rg" {
  name     = "rg-finance-prod"
  location = "East US"
  
  tags = {
    department = "finance"
    owner      = "finance-lead@nbateams.com"
  }
}

# ============================================
# RBAC ASSIGNMENTS (group-based!)
# ============================================

resource "azurerm_role_assignment" "eng_contributor" {
  scope                = azurerm_resource_group.eng_rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.engineering.id
}

resource "azurerm_role_assignment" "finance_reader" {
  scope                = azurerm_resource_group.finance_rg.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.finance.id
}

# ============================================
# OUTPUTS
# ============================================

output "eng_group_id" {
  value = azuread_group.engineering.id
}

output "finance_group_id" {
  value = azuread_group.finance.id
}
