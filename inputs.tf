locals {
  common_values_raw = {
    poc = {
      resource_group_name = "rg-poc1"
      subscription_id     = "2065a351-a257-4e4a-bafe-eba9abe51093"
      tenant_id           = "e8bff22e-8d4e-4d68-a642-4f246b9ba81e"
      location            = "East US"
      tags = {
        project   = "PoC"
        CreatedBy = "Dhanesh"
      }
    }
    test = {}
  }

  network_input_raw = {
    poc = {
      address_spaces  = ["10.29.0.0/16"]
      vnet_name       = "vnet-${terraform.workspace}"
      subnet_names    = ["subnet1", "subnet2"]
      subnet_prefixes = ["10.29.1.0/24", "10.29.2.0/24"]
    }

    test = {}

  }
  webserver_input_raw = {
    poc = {
      name = "vm-web-${terrform.workspace}"
      size = "Standard_DS1_v2"
    }

    test = {}

  }

  common_values = local.common_values_raw[terraform.workspace]
  network_input = local.network_input_raw[terraform.workspace]
}
