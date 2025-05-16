output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Azure region"
  value       = azurerm_resource_group.main.location
}

output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.main.id
}

output "web_lb_public_ip" {
  description = "Public IP address of the Web Load Balancer"
  value       = azurerm_public_ip.web_lb_public_ip.ip_address
}

output "web_vmss_name" {
  description = "Name of the Web VM Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.web_vmss.name
}

output "app_vmss_name" {
  description = "Name of the App VM Scale Set"
  value       = azurerm_linux_virtual_machine_scale_set.app_vmss.name
}

output "db_vm_private_ip" {
  description = "Private IP address of the DB VM"
  value       = azurerm_network_interface.db_nic.private_ip_address
}
