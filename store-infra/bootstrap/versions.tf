terraform {
  required_version = "= 1.17.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 5.12.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  tenant_id                       = var.tenant_id
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}
variable "subscription_id" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "stage", "production"], var.environment)
    error_message = "Choose dev, stage or production."
  }
}
variable "state_account_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.state_account_name))
    error_message = "Use a globally unique storage account name: 3-24 lowercase letters or digits."
  }
}
variable "github_repository_subject" {
  type        = string
  description = "Immutable repository identity without repo: or environment suffix; e.g. example-org@123/store-infra@456."
  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+@[0-9]+/[A-Za-z0-9_.-]+@[0-9]+$", var.github_repository_subject))
    error_message = "Use owner and repository names with immutable numeric IDs."
  }
}
