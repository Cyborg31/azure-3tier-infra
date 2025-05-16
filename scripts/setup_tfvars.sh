#!/bin/bash

echo "🚀 Let's generate your terraform.tfvars file"

# Prompt for general infrastructure info
read -rp "Enter Azure location (default: eastus): " location
location=${location:-eastus}

read -rp "Enter Resource Group name (default: my3tier-rg): " rg
rg=${rg:-my3tier-rg}

read -rp "Enter Virtual Network name (default: my3tier-vnet): " vnet
vnet=${vnet:-my3tier-vnet}

read -rp "Enter Web subnet prefix (default: 10.0.1.0/24): " web_subnet
web_subnet=${web_subnet:-10.0.1.0/24}

read -rp "Enter App subnet prefix (default: 10.0.2.0/24): " app_subnet
app_subnet=${app_subnet:-10.0.2.0/24}

read -rp "Enter DB subnet prefix (default: 10.0.3.0/24): " db_subnet
db_subnet=${db_subnet:-10.0.3.0/24}

read -rp "Enter VM size (default: Standard_B2ms): " vm_size
vm_size=${vm_size:-Standard_B2ms}

read -rp "Enter Web tier instance count (default: 2): " web_count
web_count=${web_count:-2}

read -rp "Enter App tier instance count (default: 2): " app_count
app_count=${app_count:-2}

# Prompt for Azure Service Principal credentials
read -rp "Enter Azure Subscription ID: " subscription_id
read -rp "Enter Azure Tenant ID: " tenant_id
read -rp "Enter Azure Client ID: " client_id
read -rsp "Enter Azure Client Secret: " client_secret
echo

# Read SSH key
SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"
if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "❌ SSH public key not found at $SSH_KEY_PATH"
  exit 1
fi
ssh_key=$(cat "$SSH_KEY_PATH")

TFVARS_PATH="terraform/terraform.tfvars"
mkdir -p terraform

# Write to terraform.tfvars
cat > "$TFVARS_PATH" <<EOF
location            = "$location"
resource_group_name = "$rg"
vnet_name           = "$vnet"
address_space       = ["10.0.0.0/16"]

web_subnet_name     = "web-subnet"
web_subnet_prefix   = "$web_subnet"

app_subnet_name     = "app-subnet"
app_subnet_prefix   = "$app_subnet"

db_subnet_name      = "db-subnet"
db_subnet_prefix    = "$db_subnet"

vm_size             = "$vm_size"

web_instance_count  = $web_count
app_instance_count  = $app_count

ssh_public_key      = "$ssh_key"

subscription_id     = "$subscription_id"
tenant_id           = "$tenant_id"
client_id           = "$client_id"
client_secret       = "$client_secret"
EOF

echo "✅ terraform.tfvars created successfully."
