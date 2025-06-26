# Static Web App (Frontend - Free Tier)
resource "azurerm_static_web_app" "frontend" {
  name                = var.static_webapp_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_tier            = "Free"  # Free tier has generous limits for dev/demo
  tags                = var.tags
}

# Storage Account for Function App (required for backend function app)
resource "azurerm_storage_account" "function_storage" {
  name                     = lower("backendfuncstorage31") # Storage account name must be lowercase
  resource_group_name       = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"  # Locally redundant storage - cost effective
  tags                     = var.tags
}

# App Service Plan for Function App (Y1 = Consumption Plan - cheapest)
resource "azurerm_service_plan" "function_plan" {
  name                = "${var.tags["project"]}-func-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name = "Y1"   # SKU for Consumption Plan
  os_type  = "Linux"

  tags = var.tags
}

# Function App (Linux Function App)
resource "azurerm_linux_function_app" "backend" {
  name                       = var.function_app_name
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  storage_account_name       = azurerm_storage_account.function_storage.name
  storage_account_access_key = azurerm_storage_account.function_storage.primary_access_key
  service_plan_id            = azurerm_service_plan.function_plan.id

  identity {
    type = "SystemAssigned"
  }
  site_config {}

  # App settings including DB connection info from SQL Server and Key Vault secret
  app_settings = {
    "DB_SERVER"   = azurerm_mssql_server.sql_server.fully_qualified_domain_name
    "DB_NAME"     = azurerm_mssql_database.sql_database.name
    "DB_USER"     = "dbuser"
    "DB_PASSWORD" = azurerm_key_vault_secret.db_admin_password.value
  }

  tags = var.tags
}

# Azure SQL Server instance (no public network access for security)
resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "dbuser"
  administrator_login_password = azurerm_key_vault_secret.db_admin_password.value

  public_network_access_enabled = false  # disables public internet access
  minimum_tls_version           = "1.2"

  tags = var.tags
}

# Azure SQL Database (Basic SKU to minimize cost)
resource "azurerm_mssql_database" "sql_database" {
  name        = "${var.tags["project"]}-sql-db"
  server_id   = azurerm_mssql_server.sql_server.id
  sku_name    = "Basic"
  collation   = "SQL_Latin1_General_CP1_CI_AS"

  tags = var.tags
}