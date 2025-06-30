resource "azurerm_key_vault" "main" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = var.purge_protection_enabled
  tags                       = var.tags

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Purge"
    ]
  }
}

resource "azurerm_key_vault_access_policy" "function_app_policy" {
  key_vault_id = azurerm_key_vault.main.id

  tenant_id = azurerm_linux_function_app.backend.identity[0].tenant_id
  object_id = azurerm_linux_function_app.backend.identity[0].principal_id

  secret_permissions = ["Get"]

  depends_on = [azurerm_linux_function_app.backend]
}

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!@#$%&*"
}

resource "random_password" "admin_api_key" {
  length  = 32
  special = true
}

resource "azurerm_key_vault_secret" "db_admin_password" {
  name         = "db-admin-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.main.id
  content_type = "mysql Admin Password"
  tags         = var.tags

  depends_on = [azurerm_key_vault.main]
}

resource "azurerm_key_vault_secret" "admin_api_key" {
  name         = "admin-api-key"
  value        = random_password.admin_api_key.result
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags

  depends_on = [azurerm_key_vault.main]
}