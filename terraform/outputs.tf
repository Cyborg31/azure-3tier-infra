# Public IP address of the Load Balancer
output "web_public_ip" {
  description = "The public IP address of the Web tier Load Balancer."
  value       = azurerm_public_ip.web.ip_address
}

# Public IP address of the Bastion VM (now a VM, not Bastion Host service)
output "bastion_public_ip" {
  description = "Public IP address of the Azure Bastion VM."
  value       = azurerm_public_ip.bastion_vm_ip.ip_address
}

# Private IP address of the Internal Load Balancer for App Tier
output "app_lb_private_ip" {
  description = "The private IP address of the Internal Load Balancer for the App tier."
  value       = azurerm_lb.app.frontend_ip_configuration[0].private_ip_address
}

# Private IP address of the Database VM
output "db_private_ip" {
  description = "Private IP address of the Database VM."
  value       = azurerm_network_interface.db.private_ip_address
}

# Resource Group Name
output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

# Virtual Network Name
output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = azurerm_virtual_network.main.name
}

# Subnet IDs
output "web_subnet_id" {
  description = "ID of the Web Subnet."
  value       = azurerm_subnet.web.id
}

output "app_subnet_id" {
  description = "ID of the App Subnet."
  value       = azurerm_subnet.app.id
}

output "db_subnet_id" {
  description = "ID of the DB Subnet."
  value       = azurerm_subnet.db.id
}

output "bastion_subnet_id" {
  description = "ID of the Bastion Subnet."
  value       = azurerm_subnet.bastion.id
}

# Admin username for the VMs
output "admin_username" {
  description = "The admin username for the Linux VMs."
  value       = var.admin_username
}

# Service Principal credentials output
output "sp_credentials" {
  description = "Service Principal credentials for the three-tier app."
  value = {
    client_id       = azuread_application.three_tier_app.client_id
    client_secret   = azuread_service_principal_password.three_tier_app_sp_password.value
    tenant_id       = data.azurerm_client_config.current.tenant_id
    subscription_id = data.azurerm_client_config.current.subscription_id
  }
  sensitive = true
}