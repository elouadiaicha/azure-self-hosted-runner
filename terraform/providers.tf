terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "aelouadiRG"
    storage_account_name = "staelouaditfstate"
    container_name       = "tfstate"
    key                  = "self-hosted-runner.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
}