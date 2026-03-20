##-----------------------------------------------------------------------------
## Versions
##-----------------------------------------------------------------------------
# Terraform version
terraform {
  required_version = ">= 1.10.0"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.116.0"
    }
  }
}
