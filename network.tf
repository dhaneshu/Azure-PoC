module "network" {
  source  = "Azure/network/azurerm"
  version = "5.3.0"

  use_for_each        = true
  resource_group_name = azurerm_resource_group.rg.name
  address_spaces      = local.network_input["address_spaces"]
  subnet_prefixes     = local.network_input["subnet_prefixes"]
  subnet_names        = ["subnet1", "subnet2"]
  vnet_name           = local.network_input["vnet_name"]

  subnet_service_endpoints = {
    "subnet1" : ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.Web"]
    "subnet2" : ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.Web"]
  }
  tags = local.common_values["tags"]

  depends_on = [azurerm_resource_group.rg]
}

data "azurerm_subnet" "snet" {
  for_each             = toset(local.network_input["subnet_names"])
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = local.network_input["vnet_name"]
  depends_on           = [azurerm_resource_group.rg, module.network]
}


resource "azurerm_network_security_group" "sg" {
  for_each            = toset(local.network_input["subnet_names"])
  name                = "sg-${each.key}"
  location            = local.common_values["location"]
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "sg" {
  for_each                  = toset(local.network_input["subnet_names"])
  subnet_id                 = data.azurerm_subnet.snet[each.key].id
  network_security_group_id = azurerm_network_security_group.sg[each.key].id
}
