.PHONY: all infra deploy-backend deploy-frontend

# Variables
TERRAFORM_DIR=terraform
FUNCTION_APP_NAME=function-backend  # replace with your actual function app name from terraform vars or output
FRONTEND_DIR=app/frontend
BACKEND_DIR=app/api

all: infra deploy-backend

# Initialize and apply Terraform to create infra
infra:
	cd $(TERRAFORM_DIR) && terraform init
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

# Deploy backend function app code using Azure Functions Core Tools
deploy-backend:
	func azure functionapp publish $(FUNCTION_APP_NAME) --source-path ../$(BACKEND_DIR)

# (Optional) Deploy frontend - typically Static Web Apps auto-deploy from GitHub,
# or you can push manually or automate git push in another script/step
deploy-frontend:
	cd $(FRONTEND_DIR) && git add .
	cd $(FRONTEND_DIR) && git commit -m "Deploy frontend"
	cd $(FRONTEND_DIR) && git push origin main