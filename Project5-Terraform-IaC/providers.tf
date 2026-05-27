terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "my-dev-ops-project"
    storage_account_name = "nbatfstate"
    container_name       = "tfstate"
    key                  = "project5.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
