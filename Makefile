# Makefile for 3-Tier Azure Deployment using Terraform and Ansible (Bastion Edition)

# CONFIGURATION
TERRAFORM_DIR     = terraform
ANSIBLE_DIR       = ansible
APP_DIR           = app
INVENTORY_DIR     = $(ANSIBLE_DIR)/inventory
INVENTORY_FILE    = $(INVENTORY_DIR)/hosts.ini
SSH_KEY_FILE      = ~/.ssh/id_rsa
# Resolve SSH_KEY_FILE to an absolute path for robust shell scripting
SSH_KEY_FILE_ABS := $(shell realpath $(SSH_KEY_FILE))

# PHONY TARGETS
.PHONY: all terraform generate-inventory prepare-frontend prepare-backend deploy clean pre-deploy

# FULL PIPELINE
all: terraform generate-inventory prepare-frontend prepare-backend pre-deploy deploy

# STEP 1: Terraform Infrastructure
terraform:
	@echo "🛠️  Provisioning Azure infrastructure..."
	cd $(TERRAFORM_DIR) && terraform init
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

# STEP 2: Generate Ansible Inventory (Bastion Edition)
generate-inventory:
	@echo "🔄 Generating dynamic Ansible inventory for Bastion access..."
	@mkdir -p $(INVENTORY_DIR)
	# IMPORTANT: The entire bash -c command is now on a SINGLE PHYSICAL LINE.
	# This bypasses make's multi-line processing and avoids "Unterminated quoted string" issues.
	@bash -c 'set -euo pipefail; admin=$$(cd $(TERRAFORM_DIR) && terraform output -raw admin_username); db_ip=$$(cd $(TERRAFORM_DIR) && terraform output -raw db_private_ip); bastion_ip=$$(cd $(TERRAFORM_DIR) && terraform output -raw bastion_public_ip); tf_resource_group_name=$$(cd $(TERRAFORM_DIR) && terraform output -raw resource_group_name); tf_app_lb_private_ip=$$(cd $(TERRAFORM_DIR) && terraform output -raw app_lb_private_ip); printf "%s\n" "[bastion]" > "$(INVENTORY_FILE)"; printf "bastion ansible_host=%s ansible_user=%s ansible_ssh_private_key_file=%s\n" "$$bastion_ip" "$$admin" "$(SSH_KEY_FILE_ABS)" >> "$(INVENTORY_FILE)"; printf "%s\n" "[db]" >> "$(INVENTORY_FILE)"; printf "db1 ansible_host=%s ansible_user=%s ansible_ssh_private_key_file=%s ansible_ssh_common_args='\''-o ProxyCommand=\"ssh -W %%h:%%p -q -i %s %s@%s\"'\''\n" "$$db_ip" "$$admin" "$(SSH_KEY_FILE_ABS)" "$(SSH_KEY_FILE_ABS)" "$$admin" "$$bastion_ip" >> "$(INVENTORY_FILE)"; printf "%s\n" "✅ Inventory generated at $(INVENTORY_FILE)"; printf "%s\n" "RESOURCE_GROUP_NAME=$$tf_resource_group_name" > "$(ANSIBLE_DIR)/ansible_vars.sh"; printf "%s\n" "APP_LB_PRIVATE_IP=$$tf_app_lb_private_ip" >> "$(ANSIBLE_DIR)/ansible_vars.sh"; printf "%s\n" "BASTION_PUBLIC_IP=$$bastion_ip" >> "$(ANSIBLE_DIR)/ansible_vars.sh"; printf "%s\n" "DB_PRIVATE_IP=$$db_ip" >> "$(ANSIBLE_DIR)/ansible_vars.sh"'

# STEP 3: Prepare App Files
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

# Dynamically remove known_hosts entries for newly provisioned IPs
pre-deploy:
	@echo "Cleaning known_hosts for newly provisioned Azure VM IPs..."
	. $(ANSIBLE_DIR)/ansible_vars.sh && \
	ssh-keygen -f $(HOME)/.ssh/known_hosts -R "$${BASTION_PUBLIC_IP}" || true; \
	ssh-keygen -f $(HOME)/.ssh/known_hosts -R "$${DB_PRIVATE_IP}" || true

# STEP 4: Ansible Deployment
deploy:
	@echo "🚀 Running Ansible deployment through Bastion..."
	# Source the generated vars to pass resource_group_name and app_lb_private_ip
	. $(ANSIBLE_DIR)/ansible_vars.sh && \
	ansible-playbook -i $(INVENTORY_FILE) \
	                 -i $(ANSIBLE_DIR)/azure_rm.yml \
	                 --extra-vars "resource_group_name=$${RESOURCE_GROUP_NAME} app_lb_private_ip=$${APP_LB_PRIVATE_IP}" \
	                 $(ANSIBLE_DIR)/playbooks/deploy_all.yml \
	                 --ask-vault-pass

# CLEANUP
clean:
	@echo "🧹 Cleaning up inventory and destroying infrastructure..."
	rm -f $(INVENTORY_FILE) $(ANSIBLE_DIR)/ansible_vars.sh
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve