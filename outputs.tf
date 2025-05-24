output "web_lb_public_ip" {
  value = azurerm_public_ip.web.ip_address
}

output "db_private_ip" {
  value = azurerm_network_interface.db.private_ip_address
}

output "key_vault_name" {
  value = azurerm_key_vault.main.name
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.web.ip_address}"
}