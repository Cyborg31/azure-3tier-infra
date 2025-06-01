variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Azure Virtual Network"
  type        = string
}

variable "address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "web_subnet_name" {
  description = "Name of the Web subnet"
  type        = string
}

variable "web_subnet_prefix" {
  description = "CIDR prefix for the Web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_subnet_name" {
  description = "Name of the Application subnet"
  type        = string
}

variable "app_subnet_prefix" {
  description = "CIDR prefix for the Application subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_subnet_name" {
  description = "Name of the Database subnet"
  type        = string
}

variable "db_subnet_prefix" {
  description = "CIDR prefix for the Database subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "bastion_subnet_name" {
  description = "Name of the Database subnet"
  type        = string
}

variable "bastion_subnet_prefix" {
  description = "CIDR prefix for the Azure Bastion subnet (must be /26 or larger)"
  type        = string
  default     = "10.0.5.0/26"
}

variable "my_public_ip" {
  description = "Your local machine's public IP address for SSH access to Bastion"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM instances"
  type        = string
}

variable "web_instance_count" {
  description = "Default number of VM instances for the Web Tier VM Scale Set (when no scaling event is active)"
  type        = number
}

variable "app_instance_count" {
  description = "Default number of VM instances for the App Tier VM Scale Set (when no scaling event is active)"
  type        = number
}

# Variables for Auto-Scaling Configuration

variable "web_min_instances" {
  description = "Minimum number of instances for the Web VM Scale Set"
  type        = number
  default     = 2 # Ensure at least 2 instances are always running
}

variable "web_max_instances" {
  description = "Maximum number of instances for the Web VM Scale Set"
  type        = number
  default     = 5 # Scale up to a maximum of 5 instances
}

variable "app_min_instances" {
  description = "Minimum number of instances for the App VM Scale Set"
  type        = number
  default     = 2 # Ensure at least 2 instances are always running
}

variable "app_max_instances" {
  description = "Maximum number of instances for the App VM Scale Set"
  type        = number
  default     = 5 # Scale up to a maximum of 5 instances
}

variable "scale_out_cpu_threshold_percent" {
  description = "CPU percentage threshold to trigger a scale-out event"
  type        = number
  default     = 75 # Scale out if average CPU is 75% or higher
}

variable "scale_in_cpu_threshold_percent" {
  description = "CPU percentage threshold to trigger a scale-in event"
  type        = number
  default     = 25 # Scale in if average CPU is 25% or lower
}

variable "scale_out_cooldown_minutes" {
  description = "Cooldown period in minutes after a scale-out event"
  type        = number
  default     = 5 # Wait 5 minutes before evaluating scale-out again
}

variable "scale_in_cooldown_minutes" {
  description = "Cooldown period in minutes after a scale-in event"
  type        = number
  default     = 5 # Wait 5 minutes before evaluating scale-in again
}

variable "public_lb_name" {
  description = "Name of the Public Load Balancer for Web Tier"
  type        = string
}

variable "internal_lb_name" {
  description = "Name of the Internal Load Balancer for App Tier"
  type        = string
}

variable "admin_username" {
  description = "Admin username for all VMs"
  type        = string
}

variable "ssh_public_key_secret_name" {
  description = "Name of the Key Vault secret storing SSH public key"
  type        = string
  default     = "ssh-public-key"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file (used to upload to Key Vault)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault to store secrets"
  type        = string
}

variable "purge_protection_enabled" {
  description = "Enable purge protection on Key Vault"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    environment = "dev"
    project     = "3tier-terraform"
  }
}