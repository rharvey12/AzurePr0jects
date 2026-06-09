# Storage Lifecycle Automation
# Production storage with automated tier policies
# NIST 800-53 compliance aligned

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

# Resource Group
resource "azurerm_resource_group" "storage" {
  name     = "rg-storage-lifecycle"
  location = "East US"

  tags = {
    environment = "production"
    compliance  = "NIST-800-53"
    owner       = "isso-team@nbateams.com"
    purpose     = "lifecycle-automation"
  }
}

# Random suffix for globally unique storage name
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

# Hardened Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "stlifecycle${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.storage.name
  location                 = azurerm_resource_group.storage.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"

  # Security hardening
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  shared_access_key_enabled       = false

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }

  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = true

    delete_retention_policy {
      days = 90
    }

    container_delete_retention_policy {
      days = 90
    }
  }

  tags = azurerm_resource_group.storage.tags
}

# Lifecycle Management Policy
resource "azurerm_storage_management_policy" "lifecycle" {
  storage_account_id = azurerm_storage_account.main.id

  # Rule 1: Audit logs (NIST AU-11 retention)
  rule {
    name    = "auditLogsLifecycle"
    enabled = true

    filters {
      prefix_match = ["audit-logs/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 2555
      }
    }
  }

  # Rule 2: Temp data cleanup
  rule {
    name    = "tempDataLifecycle"
    enabled = true

    filters {
      prefix_match = ["temp/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 7
      }
    }
  }

  # Rule 3: Compliance data (10-year retention)
  rule {
    name    = "complianceLifecycle"
    enabled = true

    filters {
      prefix_match = ["compliance/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 90
        tier_to_archive_after_days_since_modification_greater_than = 180
        delete_after_days_since_modification_greater_than          = 3650
      }
    }
  }

  # Rule 4: Backup data lifecycle
  rule {
    name    = "backupDataLifecycle"
    enabled = true

    filters {
      prefix_match = ["backups/"]
      blob_types   = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 14
        tier_to_archive_after_days_since_modification_greater_than = 60
        delete_after_days_since_modification_greater_than          = 365
      }
    }
  }
}

# Containers
resource "azurerm_storage_container" "audit_logs" {
  name                  = "audit-logs"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "compliance" {
  name                  = "compliance"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "backups" {
  name                  = "backups"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "temp" {
  name                  = "temp"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Log Analytics for monitoring
resource "azurerm_log_analytics_workspace" "storage_logs" {
  name                = "law-storage-lifecycle"
  location            = azurerm_resource_group.storage.location
  resource_group_name = azurerm_resource_group.storage.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

# Outputs
output "storage_account_id" {
  value = azurerm_storage_account.main.id
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "lifecycle_rules" {
  value = "4 rules: audit (7yr), temp (7d), compliance (10yr), backup (1yr)"
}

output "compliance_alignment" {
  value = "NIST 800-53: AU-11 (retention), CM-2 (baseline), MP-6 (sanitization)"
}
