# Azure Key Vault
resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  purge_protection_enabled    = var.purge_protection_enabled
  tags                        = var.tags

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
    ]
  }
}

# Upload SSH public key to Key Vault as a secret
resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = var.ssh_public_key_secret_name
  value        = file(var.ssh_public_key_path)
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [
    azurerm_key_vault.main
  ]
}
