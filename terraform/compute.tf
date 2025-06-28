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
  name                     = lower("backendfuncstorage31") # Storage account name must be lowercase and globally unique
  resource_group_name       = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"  # Locally redundant storage - cost effective
  tags                     = var.tags
}

# App Service Plan for Function App (EP1 = Elastic Premium 1)
resource "azurerm_service_plan" "function_plan" {
  name                = "${var.tags["project"]}-func-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku_name = "EP1"   
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
  "FUNCTIONS_WORKER_RUNTIME"          = "python"
  "WEBSITE_RUN_FROM_PACKAGE"         = "1"
  "DB_SERVER"                         = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  "DB_NAME"                           = azurerm_mssql_database.sql_database.name
  "DB_USER"                           = "dbuser"
  "DB_PASSWORD"                       = azurerm_key_vault_secret.db_admin_password.value
  "WEBSITE_MINIMUM_ELASTIC_INSTANCE_COUNT" = "1"
}

  tags = var.tags
}

# Function App Virtual Network Integration
# This allows the Function App to securely connect to resources within your VNet such as the private Azure SQL Database.
resource "azurerm_app_service_virtual_network_swift_connection" "backend_vnet_integration" {
  app_service_id = azurerm_linux_function_app.backend.id
  subnet_id      = azurerm_subnet.backend.id                                            
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

# Azure SQL Database
resource "azurerm_mssql_database" "sql_database" {
  name        = "${var.tags["project"]}-sql-db"
  server_id   = azurerm_mssql_server.sql_server.id
  sku_name    = "Basic"
  collation   = "SQL_Latin1_General_CP1_CI_AS"

  tags = var.tags
}

# Azure SQL Private Endpoint & Private DNS Zone
# Ensures the private SQL server is accessible via a private IP within the VNet and DNS resolution works correctly for the Function App.
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

resource "azurerm_private_dns_zone" "sql_server_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_server_dns_link" {
  name                  = "${azurerm_virtual_network.main.name}-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_server_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false # No need to register hostnames of VMs to this zone
}


# Null Resource to Initialize SQL Database Schema and Data (Bootstrap)
# This uses local-exec to run Azure CLI commands after provisioning.
# This is used for the *initial* schema creation and data seeding for the demo.
resource "null_resource" "init_sql_database" {
  depends_on = [
    azurerm_mssql_database.sql_database,
    azurerm_private_endpoint.sql_server_pe
  ]

  provisioner "local-exec" {

    command = <<-EOT
      echo "Waiting for SQL DB and Private Endpoint DNS to stabilize (60s sleep)..."
      sleep 60

      echo "Executing SQL script to initialize database..."
      az sql db execute \
        --name ${azurerm_mssql_database.sql_database.name} \
        --resource-group ${azurerm_resource_group.main.name} \
        --server ${azurerm_mssql_server.sql_server.name} \
        --admin-user "dbuser" \
        --admin-password "${azurerm_key_vault_secret.db_admin_password.value}" \
        --file ./init_db.sql
      echo "SQL script execution complete."
    EOT
    # Use "bash", "-c" for Linux/macOS. For Windows, use ["cmd", "/C"] or ["powershell", "-command"]
    interpreter = ["bash", "-c"] 
  }

  # This trigger ensures the provisioner re-runs if the SQL server resource changes,
  triggers = {
    sql_server_id = azurerm_mssql_server.sql_server.id
  }
}