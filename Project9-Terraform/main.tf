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
