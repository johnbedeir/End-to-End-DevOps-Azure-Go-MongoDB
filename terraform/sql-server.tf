resource "azurerm_sql_server" "sql_server" {
  name                         = "${var.cloudsql_name}-${var.environment}"
  resource_group_name          = azurerm_resource_group.aks.name
  location                     = azurerm_resource_group.aks.location
  version                      = "12.0"
  administrator_login          = var.db_username
  administrator_login_password = random_password.password.result

  tags = {
    environment = var.environment
  }
}

resource "azurerm_sql_database" "database" {
  name                = var.database_name
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  server_name         = azurerm_sql_server.sql_server.name
  edition             = "Basic"
  requested_service_objective_name = "Basic"
  tags = {
    environment = var.environment
  }
}

resource "azurerm_sql_firewall_rule" "allow_all" {
  name                = "AllowAll"
  resource_group_name = azurerm_resource_group.aks.name
  server_name         = azurerm_sql_server.sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_role_assignment" "aks_to_sql" {
  scope                = azurerm_sql_server.sql_server.id
  role_definition_name = "Contributor"
  principal_id         = var.aks_service_principal_id
}

resource "random_password" "password" {
  length  = 16
  special = true
}
