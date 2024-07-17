resource "azurerm_public_ip" "nat_ip" {
  name                = "${var.name_prefix}-${var.environment}-nat-ip"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gateway" {
  name                = "${var.name_prefix}-${var.environment}-nat-gateway"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gw_association" {
  nat_gateway_id  = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id    = azurerm_public_ip.nat_ip.id
}

resource "azurerm_subnet_nat_gateway_association" "nat_gw_subnet_association" {
  subnet_id       = azurerm_subnet.private_subnet.id
  nat_gateway_id  = azurerm_nat_gateway.nat_gateway.id
}
