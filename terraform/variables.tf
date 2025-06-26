variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "static_webapp_name" {
  description = "Name of the frontend static web app"
  type        = string
}

variable "function_app_name" {
  description = "Name of the backend functions app"
  type        = string
}

variable "sql_server_name" {
  description = "Name of the SQL Server"
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

variable "frontend_subnet_name" {
  description = "Name of the Web subnet"
  type        = string
}

variable "frontend_subnet_prefix" {
  description = "CIDR prefix for the Web subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "backend_subnet_name" {
  description = "Name of the Application subnet"
  type        = string
}

variable "backend_subnet_prefix" {
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

variable "admin_username" {
  description = "Admin username for all VMs"
  type        = string
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

variable "role_assignment_scope" {
  description = "Scope for SP role assignment"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    environment = "dev"
    project     = "3tier-terraform"
  }
}

variable "client_id" {
  description = "Service Principal Client ID (Application ID)"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "Service Principal Client Secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
  default     = ""
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
  default     = ""
}