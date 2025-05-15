#!/bin/bash

echo "=== Azure Service Principal Setup ==="
echo "Make sure you've run:"
echo "  az login"
echo "  az ad sp create-for-rbac --role=\"Contributor\" --scopes=\"/subscriptions/YOUR_SUBSCRIPTION_ID\""
echo "Paste the output values below."

# Collect SP credentials
read -p "Enter your Azure Subscription ID: " SUBSCRIPTION_ID
read -p "Enter your Azure Tenant ID: " TENANT_ID
read -p "Enter your Azure Client ID (appId): " CLIENT_ID
read -s -p "Enter your Azure Client Secret (password): " CLIENT_SECRET
echo ""

# Ask for region with default fallback
read -p "Enter Azure region [default: eastus]: " LOCATION
LOCATION=${LOCATION:-eastus}

# Validate SSH key
if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
  echo "❌ SSH public key not found at ~/.ssh/id_rsa.pub"
  echo "Run: ssh-keygen -t rsa -b 4096 -C \"your_email@example.com\""
  exit 1
fi

SSH_PUB_KEY=$(<~/.ssh/id_rsa.pub)

# Write tfvars file
TFVARS_PATH="terraform/terraform.tfvars"
mkdir -p terraform

cat > "$TFVARS_PATH" <<EOT
subscription_id = "$SUBSCRIPTION_ID"
tenant_id       = "$TENANT_ID"
client_id       = "$CLIENT_ID"
client_secret   = "$CLIENT_SECRET"
location        = "$LOCATION"
ssh_public_key  = "$SSH_PUB_KEY"
EOT

echo "✅ terraform.tfvars created successfully at $TFVARS_PATH"
echo "🌍 Region set to: $LOCATION"
