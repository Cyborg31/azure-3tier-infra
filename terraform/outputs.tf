output "admin_username" {
  value       = var.admin_username
  description = "Admin username for all VMs and VM Scale Sets"
}

output "jumpbox_private_ip" {
  description = "Private IP address of the Jumpbox VM"
  value       = azurerm_network_interface.jumpbox.private_ip_address
}

output "jumpbox_public_ip" {
  description = "Public IP address of the Jumpbox VM"
  value = azurerm_public_ip.jumpbox.ip_address
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

output "key_vault_name" {
  description = "Name of the Azure Key Vault resource"
  value       = azurerm_key_vault.main.name
}

output "ssh_command_jumpbox" {
  description = "SSH command to connect to the Jumpbox VM"
  value       = "ssh ${var.admin_username}@${azurerm_network_interface.jumpbox.private_ip_address}"
}

output "ssh_command_web" {
  description = "SSH command to connect to the Web tier public IP"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.web.ip_address}"
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value = {
    web     = azurerm_subnet.web.id
    app     = azurerm_subnet.app.id
    db      = azurerm_subnet.db.id
    jumpbox = azurerm_subnet.jumpbox.id
    bastion = azurerm_subnet.bastion.id
  }
}