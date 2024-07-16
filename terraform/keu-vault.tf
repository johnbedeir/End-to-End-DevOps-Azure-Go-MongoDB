resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault" "key_vault" {
  name                        = "${var.name_prefix}-${var.cloudsql_name}-kv"
  location                    = azurerm_resource_group.aks.location
  resource_group_name         = azurerm_resource_group.aks.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"

  soft_delete_enabled         = true
  purge_protection_enabled    = false
}

resource "azurerm_key_vault_access_policy" "access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.service_principal_object_id

  secret_permissions = [
    "get",
    "list",
    "set",
    "delete",
    "recover",
    "backup",
    "restore",
  ]
}

resource "azurerm_key_vault_secret" "db_username" {
  name         = "${var.name_prefix}-${var.cloudsql_name}-db-username"
  value        = var.db_username
  key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "${var.name_prefix}-${var.cloudsql_name}-db-password"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.key_vault.id
}
`