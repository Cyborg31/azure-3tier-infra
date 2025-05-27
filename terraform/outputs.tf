output "admin_username" {
  value = var.admin_username
}

output "jumpbox_private_ip" {
  description = "Private IP of Jumpbox VM"
  value       = azurerm_network_interface.jumpbox.private_ip_address
}

output "db_private_ip" {
  description = "Private IP of DB VM"
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
  description = "Public IP address of the Azure Bastion host"
  value       = azurerm_public_ip.bastion.ip_address
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.web.ip_address}"
}
