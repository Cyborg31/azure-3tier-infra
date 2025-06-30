# Azure AD Application registration
resource "azuread_application" "three-tier_app" {
  display_name = "${var.tags["project"]}"
}

# Service Principal associated with the Azure AD Application
resource "azuread_service_principal" "three-tier_app_sp" {
  client_id = azuread_application.three-tier_app.client_id
}

# Client secret (password) for the Service Principal - auto-generated
resource "azuread_service_principal_password" "three-tier_app_sp_password" {
  service_principal_id = azuread_service_principal.three-tier_app_sp.id
  end_date             = timeadd(timestamp(), "8760h") # 1 year validity
}

# Assign role to the Service Principal for Terraform deployment
resource "azurerm_role_assignment" "three-tier_app_sp_contributor_role" {
  principal_id         = azuread_service_principal.three-tier_app_sp.object_id
  role_definition_name = "Contributor"
  scope                = var.role_assignment_scope != "" ? var.role_assignment_scope : azurerm_resource_group.main.id

  depends_on = [
    azuread_service_principal.three-tier_app_sp,
    data.azurerm_client_config.current
  ]
}

# Azure Key Vault to securely store secrets
resource "azurerm_key_vault" "main" {
  name                     = var.key_vault_name
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = var.purge_protection_enabled
  tags                     = var.tags

  # Access policy for the user running Terraform locally (via az login)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Purge" # Full permissions for managing secrets
    ]
  }

  # Access policy for the CI/CD Service Principal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azuread_service_principal.three-tier_app_sp.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Purge" # Full permissions for CI/CD to manage secrets
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

# strong password for database
resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "!@#$%&*"
}

# random password for admin api
resource "random_password" "admin_api_key" {
  length  = 32
  special = true
}

# Store database password in Key Vault
resource "azurerm_key_vault_secret" "db_admin_password" {
  name         = "db-admin-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.main.id
  content_type = "mysql Admin Password"
  tags         = var.tags

  depends_on = [azurerm_key_vault.main]
}

# Store admin api key in Key Vault
resource "azurerm_key_vault_secret" "admin_api_key" {
  name         = "admin-api-key"
  value        = random_password.admin_api_key.result
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags

  depends_on = [azurerm_key_vault.main]
}


# Store Service Principal client ID as a secret in Key Vault
resource "azurerm_key_vault_secret" "sp_client_id" {
  name         = "sp-client-id"
  value        = azuread_application.three-tier_app.client_id
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags
}

# Store Service Principal client secret (password) in Key Vault
resource "azurerm_key_vault_secret" "sp_client_secret" {
  name         = "sp-client-secret"
  value        = azuread_service_principal_password.three-tier_app_sp_password.value
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags
}

# Store Azure Tenant ID in Key Vault
resource "azurerm_key_vault_secret" "sp_tenant_id" {
  name         = "tenant-id"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags
}

# Store Azure Subscription ID in Key Vault
resource "azurerm_key_vault_secret" "sp_subscription_id" {
  name         = "subscription-id"
  value        = data.azurerm_client_config.current.subscription_id
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags
}