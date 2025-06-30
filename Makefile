.PHONY: all infra frontend backend show_urls clean destroy help venv-setup build-frontend

# Configuration Variables
FRONTEND_DIR = app/frontend
BACKEND_DIR = app/backend
TERRAFORM_DIR = terraform
VENV_DIR = .venv
KEY_VAULT_NAME = my-three-tier-rg-kv

# Dynamic Variables (Fetched from Terraform Outputs)
RG_NAME := $(shell cd $(TERRAFORM_DIR) && terraform output -raw resource_group_name 2>/dev/null)
SWA_NAME := $(shell cd $(TERRAFORM_DIR) && terraform output -raw static_webapp_name 2>/dev/null)
FUNC_NAME := $(shell cd $(TERRAFORM_DIR) && terraform output -raw function_app_name 2>/dev/null)
SWA_URL := $(shell cd $(TERRAFORM_DIR) && terraform output -raw static_webapp_url 2>/dev/null)

all: infra build-frontend frontend backend show_urls
	@echo "All deployment targets finished. Check URLs above."

infra:
	@echo "--- Deploying Azure Infrastructure with Terraform ---"
	cd $(TERRAFORM_DIR) && \
	  terraform init && \
	  terraform apply -auto-approve

build-frontend:
	@echo "--- Injecting API Key into Frontend ---"
	@API_KEY=$$(az keyvault secret show --name admin-api-key --vault-name $(KEY_VAULT_NAME) --query value -o tsv); \
	sed "s/__ADMIN_API_KEY__/$$API_KEY/g" $(FRONTEND_DIR)/index.html > $(FRONTEND_DIR)/index.tmp.html && \
	mv $(FRONTEND_DIR)/index.tmp.html $(FRONTEND_DIR)/index.html

frontend:
	@echo "--- Deploying Frontend (Azure Static Web App) ---"
	@if [ -z "$(SWA_NAME)" ]; then \
	    echo "ERROR: Static Web App name not found. Run 'make infra' first."; \
	    exit 1; \
	fi
	@echo "Fetching deployment token and deploying..."
	@bash -c '\
		DEPLOYMENT_TOKEN=$$(az staticwebapp secrets list \
			--name "$(SWA_NAME)" \
			--resource-group "$(RG_NAME)" \
			--query properties.apiKey -o tsv); \
		swa deploy \
			--app-name "$(SWA_NAME)" \
			--resource-group "$(RG_NAME)" \
			--deployment-token $$DEPLOYMENT_TOKEN \
			--app-location "$(FRONTEND_DIR)"; \
	'

backend: venv-setup
	@echo "--- Deploying Backend (Azure Function App) ---"
	@if [ -z "$(FUNC_NAME)" ]; then \
	    echo "ERROR: Function App name not found. Run 'make infra' first."; \
	    exit 1; \
	fi
	@echo "Setting Python version to 3.12 on Function App: $(FUNC_NAME)"
	@az functionapp config set --name $(FUNC_NAME) --resource-group $(RG_NAME) --linux-fx-version "Python|3.12"
	@echo "Deploying backend code from $(BACKEND_DIR) to Function App: $(FUNC_NAME)"
	@cd $(BACKEND_DIR) && func azure functionapp publish $(FUNC_NAME) --python
	@echo "Backend deployment complete."

venv-setup:
	@echo "--- Setting up Python Virtual Environment and installing dependencies ---"
	@bash -c '\
	if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating virtual environment at $(VENV_DIR)..."; \
		python3 -m venv $(VENV_DIR); \
	fi; \
	echo "Installing Python dependencies from $(BACKEND_DIR)/requirements.txt..."; \
	$(VENV_DIR)/bin/pip install -r $(BACKEND_DIR)/requirements.txt; \
	'

show_urls:
	@echo "--- Deployment Complete! Your Application is Live At: ---"
	@if [ -z "$(SWA_URL)" ]; then \
	    echo "WARNING: Static Web App URL not found. Run 'make infra' first."; \
	else \
	    echo "Frontend URL: https://$(SWA_URL)"; \
	fi

clean:
	@echo "--- Cleaning up local build artifacts and Terraform state ---"
	@rm -rf $(TERRAFORM_DIR)/.terraform/
	@rm -f $(TERRAFORM_DIR)/terraform.tfstate* $(TERRAFORM_DIR)/.terraform.lock.hcl $(TERRAFORM_DIR)/terraform.tfstate.backup
	@rm -rf $(VENV_DIR)/
	@echo "Local cleanup complete."

destroy:
	@cd $(TERRAFORM_DIR) && terraform destroy -auto-approve