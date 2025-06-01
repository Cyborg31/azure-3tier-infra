# Admin username used across VMs and VM Scale Sets
output "admin_username" {
  description = "Admin username for all VMs and VM Scale Sets"
  value       = var.admin_username
  sensitive   = true
}

# Private IP address of the Database VM
output "db_private_ip" {
  description = "Private IP address of the Database VM"
  value       = azurerm_network_interface.db.private_ip_address
}

# Public IP address of the Web Load Balancer
output "web_lb_public_ip" {
  description = "Public IP address of the Web Load Balancer"
  value       = azurerm_public_ip.web.ip_address
}

# Fully qualified domain name of the Web Load Balancer
output "web_lb_fqdn" {
  description = "FQDN of the Web Load Balancer"
  value       = azurerm_public_ip.web.fqdn
}

# Private IP address of the App Load Balancer (internal)
output "app_lb_private_ip" {
  description = "Private IP address of the App Load Balancer"
  value       = azurerm_lb.app.frontend_ip_configuration[0].private_ip_address
}

# Public IP address of the Azure Bastion Host
output "bastion_public_ip" {
  description = "Public IP address of the Azure Bastion Host"
  value       = azurerm_public_ip.bastion.ip_address
}

# IDs of VM Scale Sets
output "web_vmss_instance_ids" {
  description = "Resource ID of the Web VM Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.web.id
}

output "app_vmss_instance_ids" {
  description = "Resource ID of the App VM Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.app.id
}

# Resource ID of the Database VM
output "db_vm_id" {
  description = "Resource ID of the Database VM"
  value       = azurerm_linux_virtual_machine.db.id
}

# Azure Key Vault resource name
output "key_vault_name" {
  description = "Name of the Azure Key Vault resource"
  value       = azurerm_key_vault.main.name
  sensitive   = true
}

# Subnet IDs
output "subnet_ids" {
  description = "IDs of all subnets in a map"
  value = {
    web     = azurerm_subnet.web.id
    app     = azurerm_subnet.app.id
    db      = azurerm_subnet.db.id
    bastion = azurerm_subnet.bastion.id
  }
}

# Names of VMs and VMSS resources
output "web_vmss_name" {
  description = "Name of the Web VM Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.web.name
}

output "app_vmss_name" {
  description = "Name of the App VM Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.app.name
}

output "db_vm_name" {
  description = "Name of the Database VM"
  value       = azurerm_linux_virtual_machine.db.name
}
