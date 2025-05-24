variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "eastus"
}

variable "ssh_public_key" {
  description = "SSH public key used for authenticating to the VMs"
  type        = string
}

variable "client_id" {
  description = "Azure Service Principal client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Service Principal client secret"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "app_subnet_name" {
  description = "Name of the application subnet"
  type        = string
}

variable "app_subnet_prefix" {
  description = "CIDR prefix for the application subnet"
  type        = string
}

variable "db_subnet_name" {
  description = "Name of the database subnet"
  type        = string
}

variable "db_subnet_prefix" {
  description = "CIDR prefix for the database subnet"
  type        = string
}

variable "web_subnet_name" {
  description = "Name of the web subnet"
  type        = string
}

variable "web_subnet_prefix" {
  description = "CIDR prefix for the web subnet"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

# New variables for scaling

variable "web_instance_count" {
  description = "Number of VM instances in the Web Tier VM Scale Set"
  type        = number
  default     = 2
}

variable "app_instance_count" {
  description = "Number of VM instances in the App Tier VM Scale Set"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of the VM instances"
  type        = string
  default     = "Standard_DS1_v2"
}

# Load Balancer related variables

variable "public_lb_name" {
  description = "Name of the Public Load Balancer for Web Tier"
  type        = string
  default     = "web-pub-lb"
}

variable "internal_lb_name" {
  description = "Name of the Internal Load Balancer for App Tier"
  type        = string
  default     = "app-int-lb"
}