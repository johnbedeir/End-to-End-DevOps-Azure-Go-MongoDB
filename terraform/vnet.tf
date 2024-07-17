resource "azurerm_public_ip" "external_ip" {
  name                = "${var.name_prefix}-${var.environment}-external-ip"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network" "vpc_network" {
  name                = "${var.name_prefix}-${var.environment}-vpc"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "${var.name_prefix}-${var.environment}-public-subnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.vpc_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "${var.name_prefix}-${var.environment}-private-subnet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.vpc_network.name
  address_prefixes     = ["10.0.2.0/24"]
}
