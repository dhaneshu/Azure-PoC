resource "azurerm_resource_group" "rg" {
  name     = local.common_values["resource_group_name"]
  location = local.common_values["location"]
}
