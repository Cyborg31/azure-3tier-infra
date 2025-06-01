# Values for variables

location            = "eastus"
resource_group_name = "my3tier-rg"

vnet_name     = "my3tier-vnet"
address_space = ["10.0.0.0/16"]

web_subnet_name   = "web-subnet"
web_subnet_prefix = "10.0.1.0/24"

app_subnet_name   = "app-subnet"
app_subnet_prefix = "10.0.2.0/24"

db_subnet_name   = "db-subnet"
db_subnet_prefix = "10.0.3.0/24"

bastion_subnet_prefix = "10.0.5.0/26" # Azure Bastion requires /26 or larger subnet

vm_size            = "Standard_B2s" # Changed from B1ls to B2s for a more reasonable starting point
web_instance_count = 2 # This is now the 'default' for auto-scaling
app_instance_count = 2 # This is now the 'default' for auto-scaling

# Auto-scaling parameters
web_min_instances          = 2
web_max_instances          = 5
app_min_instances          = 2
app_max_instances          = 5
scale_out_cpu_threshold_percent = 75
scale_in_cpu_threshold_percent  = 25
scale_out_cooldown_minutes      = 5
scale_in_cooldown_minutes       = 5

public_lb_name   = "web-pub-lb"
internal_lb_name = "app-int-lb"

admin_username             = "azureuser"
ssh_public_key_secret_name = "ssh-public-key"
ssh_public_key_path        = "~/.ssh/id_rsa.pub"
allowed_ssh_ip             = "*" # Change to your IP for better security
key_vault_name             = "my3tier-rg-kv"

purge_protection_enabled = false

tags = {
  environment = "dev"
  project     = "3tier-terraform"
}