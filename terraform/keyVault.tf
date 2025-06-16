# Create an Azure AD Application for your 3-tier app
resource "azuread_application" "three_tier_app" {
  display_name = "three-tier-app"
}

# Create the Service Principal for the Azure AD Application
resource "azuread_service_principal" "three_tier_app_sp" {
  client_id = azuread_application.three_tier_app.client_id
}

# Create a password (client secret) for the SP - auto-generated
resource "azuread_service_principal_password" "three_tier_app_sp_password" {
  service_principal_id = azuread_service_principal.three_tier_app_sp.id
  end_date = timeadd(timestamp(), "8760h")  # 1 year from now
}

# Create Azure Key Vault to store secrets securely
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
      "Recover",
      "Purge",
    ]
  }
}

# Upload SSH public key to Key Vault as a secret
resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = var.ssh_public_key_secret_name
  value        = file(var.ssh_public_key_path)
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

# Store SP client ID in Key Vault
resource "azurerm_key_vault_secret" "sp_client_id" {
  name         = "sp-client-id"
  value        = azuread_application.three_tier_app.client_id
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

# Store SP client secret in Key Vault (auto-generated)
resource "azurerm_key_vault_secret" "sp_client_secret" {
  name         = "sp-client-secret"
  value        = azuread_service_principal_password.three_tier_app_sp_password.value
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

# Store tenant ID in Key Vault
resource "azurerm_key_vault_secret" "sp_tenant_id" {
  name         = "sp-tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}

# Store subscription ID in Key Vault
resource "azurerm_key_vault_secret" "sp_subscription_id" {
  name         = "sp-subscription-id"
  value        = data.azurerm_client_config.current.subscription_id
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_key_vault.main]
}