# Static Web App (Frontend - Free Tier)
resource "azurerm_static_web_app" "frontend" {
  name                = var.static_webapp_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_tier            = "Free"
  tags                = var.tags
}

# Storage Account for Function App
resource "azurerm_storage_account" "function_storage" {
  name                     = lower("backendfuncstorage31") # lowercase & globally unique
  resource_group_name       = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# App Service Plan (Elastic Premium)
resource "azurerm_service_plan" "function_plan" {
  name                = "${var.tags["project"]}-func-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name = "EP1"
  os_type  = "Linux"
  tags     = var.tags
}

# Application Insights Resource
resource "azurerm_application_insights" "app_insights" {
  name                = "${var.tags["project"]}-app-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
}

# Function App (Linux)
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

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"                = "python"
    "WEBSITE_RUN_FROM_PACKAGE"                = "1"
    "WEBSITE_VNET_ROUTE_ALL"                  = "1"
    "DB_SERVER"                               = azurerm_mssql_server.sql_server.fully_qualified_domain_name
    "DB_NAME"                                 = azurerm_mssql_database.sql_database.name
    "DB_USER"                                 = "dbuser"
    "DB_PASSWORD"                             = azurerm_key_vault_secret.db_admin_password.value
    "ADMIN_API_KEY"                           = azurerm_key_vault_secret.admin_api_key.value
    "WEBSITE_MINIMUM_ELASTIC_INSTANCE_COUNT"  = "1"
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights.connection_string
  }

  tags = var.tags

  depends_on = [
    azurerm_key_vault_secret.db_admin_password,
    azurerm_key_vault_secret.admin_api_key
  ]
}

# VNet Integration for Function App
resource "azurerm_app_service_virtual_network_swift_connection" "backend_vnet_integration" {
  app_service_id = azurerm_linux_function_app.backend.id
  subnet_id      = azurerm_subnet.backend.id
}

# Azure SQL Server (Private)
resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "dbuser"
  administrator_login_password = azurerm_key_vault_secret.db_admin_password.value

  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
  tags                         = var.tags
}

# Azure SQL Database
resource "azurerm_mssql_database" "sql_database" {
  name      = "${var.tags["project"]}-sql-db"
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "Basic"
  collation = "SQL_Latin1_General_CP1_CI_AS"
  tags      = var.tags
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql_server_pe" {
  name                = "${azurerm_mssql_server.sql_server.name}-pe"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.db.id

  private_service_connection {
    name                           = "${azurerm_mssql_server.sql_server.name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_server_dns_zone.id]
  }
}

# Private DNS Zone & Link for SQL Server
resource "azurerm_private_dns_zone" "sql_server_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_server_dns_link" {
  name                  = "${azurerm_virtual_network.main.name}-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_server_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
}