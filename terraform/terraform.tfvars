location            = "westus2"
resource_group_name = "three-tier-rg"
static_webapp_name  = "static-frontend"
function_app_name   = "backend-func-3tier"
sql_server_name     = "3tdbs"

vnet_name           = "my-three-tier-vnet"
address_space       = ["10.0.0.0/16"]

frontend_subnet_name   = "frontend-subnet"
frontend_subnet_prefix = "10.0.1.0/24"

backend_subnet_name    = "backend-subnet"
backend_subnet_prefix  = "10.0.2.0/24"

db_subnet_name         = "db-subnet"
db_subnet_prefix       = "10.0.3.0/24"

admin_username         = "azureuser"
key_vault_name         = "my-three-tier-rg-kv"

purge_protection_enabled = false

tags = {
  environment = "dev"
  project     = "three-tier-app"
}