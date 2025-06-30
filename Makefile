.PHONY: all infra frontend backend show_urls clean destroy help venv-setup init-db-trigger

# Configuration Variables
FRONTEND_DIR := app/frontend
BACKEND_DIR := app/backend
TERRAFORM_DIR := terraform
VENV_DIR := .venv

all: infra frontend backend init-db-trigger show_urls
	@echo ""
	@echo "✅ All deployment targets finished. Check URLs above."

infra:
	@echo "--- 🚀 Deploying Azure Infrastructure with Terraform ---"
	@cd $(TERRAFORM_DIR) && \
	terraform init && \
	terraform apply -auto-approve || { echo "❌ ERROR: Terraform infrastructure deployment failed!"; exit 1; }

frontend: infra
	@echo "--- 🚀 Deploying Frontend (Azure Static Web App) ---"
	@SWA_NAME=$$(cd $(TERRAFORM_DIR) && terraform output -raw static_webapp_name 2>/dev/null); \
	RG_NAME=$$(cd $(TERRAFORM_DIR) && terraform output -raw resource_group_name 2>/dev/null); \
	if [ -z "$$SWA_NAME" ]; then \
		echo "❌ ERROR: Static Web App name not found."; exit 1; \
	fi; \
	echo "⏳ Waiting for Static Web App deployment token..."; \
	MAX_RETRIES=15; RETRY_COUNT=0; \
	while :; do \
		DEPLOYMENT_TOKEN=$$(az staticwebapp secrets list --name "$$SWA_NAME" --resource-group "$$RG_NAME" --query properties.apiKey -o tsv 2>/dev/null); \
		if [ -n "$$DEPLOYMENT_TOKEN" ]; then break; fi; \
		if [ $$RETRY_COUNT -ge $$MAX_RETRIES ]; then \
			echo "❌ ERROR: Deployment token not available."; exit 1; \
		fi; \
		echo "  ⏳ Token wait: $$RETRY_COUNT/$$MAX_RETRIES"; \
		sleep 2; RETRY_COUNT=$$(($$RETRY_COUNT + 1)); \
	done; \
	echo "🔑 Token acquired. Deploying from $(FRONTEND_DIR)..."; \
	swa deploy --app-name "$$SWA_NAME" \
	           --resource-group "$$RG_NAME" \
	           --deployment-token $$DEPLOYMENT_TOKEN \
	           --app-location "$(FRONTEND_DIR)" || { echo "❌ ERROR: Static Web App deployment failed!"; exit 1; }; \
	echo "✅ Frontend deployment complete."

backend: venv-setup
	@echo "--- 🚀 Deploying Backend (Azure Function App) ---"
	@FUNC_NAME=$$(cd $(TERRAFORM_DIR) && terraform output -raw function_app_name 2>/dev/null); \
	RG_NAME=$$(cd $(TERRAFORM_DIR) && terraform output -raw resource_group_name 2>/dev/null); \
	if [ -z "$$FUNC_NAME" ]; then \
		echo "❌ ERROR: Function App name not found."; exit 1; \
	fi; \
	echo "⏳ Waiting for Function App readiness..."; \
	MAX_RETRIES=15; RETRY_COUNT=0; \
	while ! az functionapp show --name $$FUNC_NAME --resource-group $$RG_NAME >/dev/null 2>&1; do \
		if [ $$RETRY_COUNT -ge $$MAX_RETRIES ]; then \
			echo "❌ ERROR: Function App not ready."; exit 1; \
		fi; \
		echo "  ⏳ Wait: $$RETRY_COUNT/$$MAX_RETRIES"; \
		sleep 2; RETRY_COUNT=$$(($$RETRY_COUNT + 1)); \
	done; \
	echo "🔧 Setting Python version for $$FUNC_NAME..."; \
	az functionapp config set --name $$FUNC_NAME --resource-group $$RG_NAME --linux-fx-version "Python|3.12" || { echo "❌ ERROR: Failed to set Python version."; exit 1; }; \
	echo "🚀 Publishing backend from $(BACKEND_DIR)..."; \
	cd $(BACKEND_DIR) && func azure functionapp publish $$FUNC_NAME --python || { echo "❌ ERROR: Backend publish failed!"; exit 1; }; \
	echo "✅ Backend deployment complete."

init-db-trigger:
	@echo "--- 🚀 Triggering init-db function ---"
	@FUNC_NAME=$$(cd $(TERRAFORM_DIR) && terraform output -raw function_app_name); \
	RG_NAME=$$(cd $(TERRAFORM_DIR) && terraform output -raw resource_group_name); \
	KEY_VAULT_NAME=$$(cd $(TERRAFORM_DIR) && terraform output -raw key_vault_name); \
	echo "⏳ Waiting for admin-api-key secret..."; \
	MAX_RETRIES=15; RETRY_COUNT=0; \
	while ! az keyvault secret show --name admin-api-key --vault-name $$KEY_VAULT_NAME --query value -o tsv >/dev/null 2>&1; do \
		if [ $$RETRY_COUNT -ge $$MAX_RETRIES ]; then echo "❌ ERROR: admin-api-key not found."; exit 1; fi; \
		echo "  ⏳ Wait: $$RETRY_COUNT/$$MAX_RETRIES"; sleep 2; RETRY_COUNT=$$(($$RETRY_COUNT + 1)); \
	done; \
	ADMIN_API_KEY_RAW=$$(az keyvault secret show --name admin-api-key --vault-name $$KEY_VAULT_NAME --query value -o tsv); \
	ADMIN_API_KEY=$$(python3 -c 'import urllib.parse; print(urllib.parse.quote_plus("'"$$ADMIN_API_KEY_RAW"'"))'); \
	echo "⏳ Waiting for init-db function key..."; \
	RETRY_COUNT=0; \
	while ! az functionapp function keys list --resource-group $$RG_NAME --name $$FUNC_NAME --function-name init-db --query 'default' -o tsv >/dev/null 2>&1; do \
		if [ $$RETRY_COUNT -ge $$MAX_RETRIES ]; then echo "❌ ERROR: Function key not ready."; exit 1; fi; \
		echo "  ⏳ Wait: $$RETRY_COUNT/$$MAX_RETRIES"; sleep 2; RETRY_COUNT=$$(($$RETRY_COUNT + 1)); \
	done; \
	INIT_DB_FUNC_KEY=$$(az functionapp function keys list --resource-group $$RG_NAME --name $$FUNC_NAME --function-name init-db --query 'default' -o tsv); \
	FUNC_URL="https://$$FUNC_NAME.azurewebsites.net/api/init-db?code=$$INIT_DB_FUNC_KEY&key=$$ADMIN_API_KEY"; \
	echo "🔗 Triggering URL: $$FUNC_URL"; \
	HTTP_STATUS=$$(curl -s -o /dev/null -w "%{http_code}" -X GET "$$FUNC_URL"); \
	case $$HTTP_STATUS in \
		200) echo "✅ init-db triggered successfully (HTTP 200)";; \
		401) echo "❌ ERROR: Unauthorized (401). Check admin-api-key."; exit 1;; \
		404) echo "❌ ERROR: Not Found (404). Is init-db deployed?"; exit 1;; \
		500) echo "❌ ERROR: Internal Server Error (500). Check logs."; exit 1;; \
		*) echo "❌ ERROR: Unexpected status $$HTTP_STATUS"; exit 1;; \
	esac

venv-setup:
	@echo "--- 🐍 Setting up Python virtual environment ---"
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating virtualenv..."; \
		python3 -m venv $(VENV_DIR) || { echo "❌ ERROR: venv failed."; exit 1; }; \
	fi; \
	echo "📦 Installing dependencies..."; \
	$(VENV_DIR)/bin/pip install --upgrade pip; \
	$(VENV_DIR)/bin/pip install -r $(BACKEND_DIR)/requirements.txt || { echo "❌ ERROR: pip install failed."; exit 1; }

show_urls:
	@echo "--- 🌐 Application URLs ---"
	@cd $(TERRAFORM_DIR); \
	SWA_URL=$$(terraform output -raw static_web_app_url 2>/dev/null); \
	FUNC_NAME=$$(terraform output -raw function_app_name 2>/dev/null); \
	if [ -n "$$SWA_URL" ]; then echo "🌍 Frontend: https://$$SWA_URL"; else echo "⚠️ Static Web App URL missing."; fi; \
	if [ -n "$$FUNC_NAME" ]; then echo "🛠️ Backend: https://$$FUNC_NAME.azurewebsites.net"; else echo "⚠️ Function App missing."; fi

clean:
	@echo "--- 🧹 Cleaning up ---"
	@rm -rf $(TERRAFORM_DIR)/.terraform/ $(TERRAFORM_DIR)/terraform.tfstate* $(TERRAFORM_DIR)/.terraform.lock.hcl
	@rm -rf $(VENV_DIR)
	@echo "✅ Cleanup complete."

destroy:
	@echo "--- 💣 Destroying infrastructure ---"
	@cd $(TERRAFORM_DIR) && terraform destroy -auto-approve || { echo "❌ ERROR: Terraform destroy failed."; exit 1; }
	@echo "✅ Infrastructure destroyed."

help:
	@echo "📖 Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all             : Deploy infra + frontend + backend + DB init"
	@echo "  infra           : Terraform infra deployment"
	@echo "  frontend        : Deploy frontend to Azure Static Web Apps"
	@echo "  backend         : Deploy backend to Azure Function App"
	@echo "  init-db-trigger : Call backend/init-db to initialize database"
	@echo "  venv-setup      : Setup Python virtual environment"
	@echo "  show_urls       : Print frontend/backend URLs"
	@echo "  clean           : Remove local build artifacts"
	@echo "  destroy         : Tear down Azure resources"
	@echo "  help            : Show this help message"
