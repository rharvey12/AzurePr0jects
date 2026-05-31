data "azurerm_subscription" "current" {}

resource "azurerm_subscription_policy_assignment" "nist_800_53" {
  name                 = "nist-800-53-rev5"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/179d1daa-458f-4e47-8086-2a68d0d6c38f"
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "NIST SP 800-53 Rev. 5"
  description          = "NIST 800-53 Rev 5 compliance scanning"
  location             = "eastus"

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({})
}

output "nist_assignment_id" {
  value = azurerm_subscription_policy_assignment.nist_800_53.id
}


# Custom Policy 1: NIST SC-28 - Require Storage Encryption
resource "azurerm_policy_definition" "require_storage_https" {
  name         = "nist-sc8-require-https-storage"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "NIST SC-8: Storage Accounts Must Use HTTPS"
  description  = "Audits storage accounts that don't enforce HTTPS-only traffic"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          field  = "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly"
          equals = "false"
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

# Custom Policy 2: NIST SC-7 - Require NSG on Subnets
resource "azurerm_policy_definition" "require_nsg_on_subnet" {
  name         = "nist-sc7-require-nsg"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "NIST SC-7: Subnets Must Have NSG Attached"
  description  = "Audits subnets that don't have a Network Security Group attached"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Network/virtualNetworks/subnets"
        },
        {
          field  = "Microsoft.Network/virtualNetworks/subnets/networkSecurityGroup.id"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

# Custom Policy 3: NIST AU-11 - Require Log Analytics Retention
resource "azurerm_policy_definition" "require_log_retention" {
  name         = "nist-au11-log-retention"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "NIST AU-11: Log Analytics Must Have 90+ Day Retention"
  description  = "Audits Log Analytics workspaces with less than 90 day retention"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.OperationalInsights/workspaces"
        },
        {
          field  = "Microsoft.OperationalInsights/workspaces/retentionInDays"
          less   = 90
        }
      ]
    }
    then = {
      effect = "audit"
    }
  })
}

# Assign all custom policies to subscription
resource "azurerm_subscription_policy_assignment" "https_policy" {
  name                 = "audit-storage-https"
  policy_definition_id = azurerm_policy_definition.require_storage_https.id
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Audit Storage HTTPS Requirement"
}

resource "azurerm_subscription_policy_assignment" "nsg_policy" {
  name                 = "audit-subnet-nsg"
  policy_definition_id = azurerm_policy_definition.require_nsg_on_subnet.id
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Audit Subnet NSG Requirement"
}

resource "azurerm_subscription_policy_assignment" "retention_policy" {
  name                 = "audit-log-retention"
  policy_definition_id = azurerm_policy_definition.require_log_retention.id
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = "Audit Log Retention Requirement"
}


# Action Group for Compliance Alerts
resource "azurerm_monitor_action_group" "compliance_alerts" {
  name                = "nist-compliance-alerts"
  resource_group_name = "nbateams"
  short_name          = "nistalert"

  email_receiver {
    name                    = "compliance-team"
    email_address           = "Harveyr@roderickharvey10gmail.onmicrosoft.com"
    use_common_alert_schema = true
  }
}

# Activity Log Alert - Policy Violation Detected
resource "azurerm_monitor_activity_log_alert" "policy_violations" {
  name                = "nist-policy-violation-alert"
  resource_group_name = "nbateams"
  location            = "global"
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Alert when Azure Policy detects NIST violations"

  criteria {
    category       = "Policy"
    operation_name = "Microsoft.Authorization/policies/audit/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.compliance_alerts.id
  }
}


