output "resource_group_name" {
  description = "Name of the main resource group"
  value       = azurerm_resource_group.main.name
}

output "static_web_app_url" {
  description = "URL of the Azure Static Web App frontend"
  value       = azurerm_static_web_app.frontend.default_host_name
}

output "static_webapp_name" {
  description = "Name of the Azure Static Web App resource"
  value       = azurerm_static_web_app.frontend.name
}

output "function_app_name" {
  description = "Name of the Azure Function App resource"
  value       = azurerm_linux_function_app.backend.name
}

output "function_app_default_hostname" {
  description = "Default hostname of the Azure Linux Function App backend"
  value       = azurerm_linux_function_app.backend.default_hostname
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of Azure SQL Server"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
  description = "The name of the Key Vault."
}