# Location and Resource Group
location            = "eastus"
resource_group_name = "my3tier-rg"

# Virtual Network Configuration
vnet_name           = "my3tier-vnet"
address_space       = ["10.0.0.0/16"]

# Subnet Configuration
web_subnet_name     = "web-subnet"
web_subnet_prefix   = "10.0.1.0/24"

app_subnet_name     = "app-subnet"
app_subnet_prefix   = "10.0.2.0/24"

db_subnet_name      = "db-subnet"
db_subnet_prefix    = "10.0.3.0/24"

# Compute Configuration
vm_size             = "Standard_B1ls"
web_instance_count  = 2
app_instance_count  = 2

# Load Balancer Configuration
public_lb_name      = "web-pub-lb"
internal_lb_name    = "app-int-lb"

# Authentication Configuration
admin_username               = "azureuser"
ssh_public_key_secret_name   = "ssh-public-key"
ssh_public_key_path          = "~/.ssh/id_rsa.pub"
allowed_ssh_ip               = "*"  # Replace with your IP or CIDR
key_vault_name               = "my3tier-rg-kv"

# Resource Tags
tags = {
  environment = "dev"
  project     = "3tier-terraform"
}