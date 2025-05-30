variable "location" {
  description = "Azure region"
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
  default     = ["10.0.0.0/16"]
}

variable "web_subnet_name" {
  description = "Name of the web subnet"
  type        = string
}

variable "web_subnet_prefix" {
  description = "CIDR prefix for the web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_subnet_name" {
  description = "Name of the application subnet"
  type        = string
}

variable "app_subnet_prefix" {
  description = "CIDR prefix for the application subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_subnet_name" {
  description = "Name of the database subnet"
  type        = string
}

variable "db_subnet_prefix" {
  description = "CIDR prefix for the database subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "bastion_subnet_prefix" {
  description = "CIDR prefix for the Azure Bastion subnet"
  type        = string
  default     = "10.0.5.0/26"
}

variable "vm_size" {
  description = "Size of the VM instances"
  type        = string
}

variable "web_instance_count" {
  description = "Number of VM instances in the Web Tier VM Scale Set"
  type        = number
}

variable "app_instance_count" {
  description = "Number of VM instances in the App Tier VM Scale Set"
  type        = number
}

variable "public_lb_name" {
  description = "Name of the Public Load Balancer"
  type        = string
}

variable "internal_lb_name" {
  description = "Name of the Internal Load Balancer"
  type        = string
}

variable "admin_username" {
  description = "Admin username for all VMs"
  type        = string
}

variable "ssh_public_key_secret_name" {
  description = "Name of the Key Vault secret for SSH public key"
  type        = string
  default     = "ssh-public-key"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file (used once to upload to Key Vault)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "allowed_ssh_ip" {
  description = "IP address or CIDR allowed to connect via SSH"
  type        = string
  default     = "*"  #
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
}

variable "purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {
    environment = "dev"
    project     = "3-tier-app"
  }
}