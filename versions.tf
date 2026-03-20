terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "# Terraform version"
    }
  }
  provider_meta "azurerm" {
    module_name = "terraform-az-modules/terraform-azurerm-load-balancer"
  }
}
