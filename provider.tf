terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.64.0"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "3.2.0"
    # }

  }
}

provider "azurerm" {
  subscription_id = local.common_values["subscription_id"]
  tenant_id       = local.common_values["tenant_id"]
  features {}
}


# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-tfstate"
#     storage_account_name = "sgpoctfstatefile"
#     container_name       = "tfstate"
#     key                  = "azure-poc.tfstate"
#     subscription_id      = "2065a351-a257-4e4a-bafe-eba9abe51093"
#     tenant_id            = "e8bff22e-8d4e-4d68-a642-4f246b9ba81e"
#   }
# }
