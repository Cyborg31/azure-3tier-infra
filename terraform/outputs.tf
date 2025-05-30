output "admin_username" {
  value       = var.admin_username
  description = "Admin username for all VMs and VM Scale Sets"
}

output "db_private_ip" {
  description = "Private IP address of the Database VM"
  value       = azurerm_network_interface.db.private_ip_address
}

output "web_lb_public_ip" {
  description = "Public IP address of the Web Load Balancer"
  value       = azurerm_public_ip.web.ip_address
}

output "app_lb_private_ip" {
  description = "Private IP address of the App Load Balancer"
  value       = azurerm_lb.app.frontend_ip_configuration[0].private_ip_address
}

output "bastion_public_ip" {
  description = "Public IP address of the Azure Bastion Host"
  value       = azurerm_public_ip.bastion.ip_address
}

output "web_vmss_instance_ids" {
  value = azurerm_linux_virtual_machine_scale_set.web.id
}

output "app_vmss_instance_ids" {
  value = azurerm_linux_virtual_machine_scale_set.app.id
}

output "db_vm_id" {
  value = azurerm_linux_virtual_machine.db.id
}

output "key_vault_name" {
  description = "Name of the Azure Key Vault resource"
  value       = azurerm_key_vault.main.name
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value = {
    web     = azurerm_subnet.web.id
    app     = azurerm_subnet.app.id
    db      = azurerm_subnet.db.id
    bastion = azurerm_subnet.bastion.id
  }
}

# Outputs for VM and VMSS names to use with az ssh

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
