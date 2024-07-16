resource "azurerm_container_registry" "acr" {
  name                = "${var.name_prefix}${var.environment}acr"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku                 = "Standard"
  admin_enabled       = true
}
