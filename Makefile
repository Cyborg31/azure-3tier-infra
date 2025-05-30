# Makefile for 3-Tier Azure Deployment using Terraform and Ansible

#CONFIGURATION
TERRAFORM_DIR     = terraform
ANSIBLE_DIR       = ansible
APP_DIR           = app
INVENTORY_DIR     = $(ANSIBLE_DIR)/inventory
INVENTORY_FILE    = $(INVENTORY_DIR)/hosts.ini
SSH_KEY_FILE      = ~/.ssh/id_rsa

#PHONY TARGETS
.PHONY: all terraform generate-inventory prepare-frontend prepare-backend deploy clean

#FULL PIPELINE
all: terraform generate-inventory prepare-frontend prepare-backend deploy

#STEP 1: Terraform Infrastructure
terraform:
	cd $(TERRAFORM_DIR) && terraform init
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

# STEP 2: Generate Ansible Inventory
generate-inventory:
	@echo "🔄 Generating dynamic Ansible inventory..."
	@mkdir -p $(INVENTORY_DIR)

	@bash -c '\
	set -euo pipefail; \
	admin=$$(cd $(TERRAFORM_DIR) && terraform output -raw admin_username); \
	jumpbox_ip=$$(cd $(TERRAFORM_DIR) && terraform output -raw jumpbox_public_ip); \
	db_ip=$$(cd $(TERRAFORM_DIR) && terraform output -raw db_private_ip); \
	web_lb_ip=$$(cd $(TERRAFORM_DIR) && terraform output -raw web_lb_public_ip); \
	app_lb_ip=$$(cd $(TERRAFORM_DIR) && terraform output -raw app_lb_private_ip); \
	\
	echo "[jumpbox]" > $(INVENTORY_FILE); \
	echo "jumpbox ansible_host=$$jumpbox_ip ansible_user=$$admin ansible_ssh_private_key_file=$(SSH_KEY_FILE)" >> $(INVENTORY_FILE); \
	\
	echo "[db]" >> $(INVENTORY_FILE); \
	echo "db1 ansible_host=$$db_ip ansible_user=$$admin ansible_ssh_private_key_file=$(SSH_KEY_FILE) ansible_ssh_common_args='\''-o ProxyJump=$$admin@$$jumpbox_ip -o ForwardAgent=yes'\''" >> $(INVENTORY_FILE); \
	\
	echo "[web]" >> $(INVENTORY_FILE); \
	echo "web1 ansible_host=$$web_lb_ip ansible_user=$$admin ansible_ssh_private_key_file=$(SSH_KEY_FILE)" >> $(INVENTORY_FILE); \
	\
	echo "[app]" >> $(INVENTORY_FILE); \
	echo "app1 ansible_host=$$app_lb_ip ansible_user=$$admin ansible_ssh_private_key_file=$(SSH_KEY_FILE) ansible_ssh_common_args='\''-o ProxyJump=$$admin@$$jumpbox_ip -o ForwardAgent=yes'\''" >> $(INVENTORY_FILE); \
	\
	echo "Inventory generated at $(INVENTORY_FILE)"; \
	'

#STEP 3: Prepare App Files
prepare-frontend:
	@echo "📦 Preparing frontend files..."
	rm -rf $(ANSIBLE_DIR)/files/frontend
	mkdir -p $(ANSIBLE_DIR)/files/frontend
	cp -r $(APP_DIR)/frontend/* $(ANSIBLE_DIR)/files/frontend/

prepare-backend:
	@echo "📦 Preparing backend files..."
	rm -rf $(ANSIBLE_DIR)/files/backend
	mkdir -p $(ANSIBLE_DIR)/files/backend
	cp -r $(APP_DIR)/backend/* $(ANSIBLE_DIR)/files/backend/

#STEP 4: Ansible Deployment
deploy:
	@echo "🚀 Running Ansible deployment..."
	ansible-playbook -i $(INVENTORY_FILE) $(ANSIBLE_DIR)/playbooks/deploy_all.yml

#CLEANUP
clean:
	@echo "🧹 Cleaning up inventory and destroying infrastructure..."
	rm -f $(INVENTORY_FILE)
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve
