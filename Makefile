TF_DIR = terraform
ANSIBLE_DIR = ansible
APP_DIR = app

WEB_PUBLIC_IP := $(shell terraform -chdir=$(TF_DIR) output -raw web_public_ip)
BASTION_PUBLIC_IP := $(shell terraform -chdir=$(TF_DIR) output -raw bastion_public_ip)
DB_PRIVATE_IP := $(shell terraform -chdir=$(TF_DIR) output -raw db_private_ip)
RESOURCE_GROUP := $(shell terraform -chdir=$(TF_DIR) output -raw resource_group_name)
ADMIN_USER := $(shell terraform -chdir=$(TF_DIR) output -raw admin_username)

.PHONY: all terraform ansible-generate-inventory ansible-deploy destroy

all: terraform ansible-generate-inventory ansible-deploy

terraform:
	terraform -chdir=$(TF_DIR) init
	terraform -chdir=$(TF_DIR) apply -auto-approve

ansible-generate-inventory:
	@echo "Generating hosts.ini and azure_rm.yml with Terraform outputs..."

	@mkdir -p $(ANSIBLE_DIR)/inventory

	# Start with bastion group
	@echo "[bastion]" > $(ANSIBLE_DIR)/inventory/hosts.ini
	@echo "bastion ansible_host=$(BASTION_PUBLIC_IP) ansible_user=$(ADMIN_USER)" >> $(ANSIBLE_DIR)/inventory/hosts.ini

	# Add db group and dbhost BELOW the bastion config within hosts.ini
	@echo "" >> $(ANSIBLE_DIR)/inventory/hosts.ini
	@echo "[db]" >> $(ANSIBLE_DIR)/inventory/hosts.ini
	@echo "dbhost ansible_host=$(DB_PRIVATE_IP) ansible_user=$(ADMIN_USER) ansible_ssh_common_args='-o ProxyJump=$(ADMIN_USER)@$(BASTION_PUBLIC_IP)'" >> $(ANSIBLE_DIR)/inventory/hosts.ini

	# Generate azure_rm.yml for dynamic inventory
	@echo "plugin: azure_rm" > $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "include_vm_resource_groups:" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "  - $(RESOURCE_GROUP)" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "auth_source: auto" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "filters:" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "  resource_type: \"Microsoft.Compute/virtualMachineScaleSets\"" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "keyed_groups:" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "  - key: tags.Tier" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "    prefix: ''" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "hostnames:" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "  - vmName" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "compose:" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml
	@echo "  ansible_host: privateIpAddress" >> $(ANSIBLE_DIR)/inventory/azure_rm.yml

ansible-deploy:
	# Use --limit db for the group, as dbhost is now correctly within the [db] group
	ansible-playbook -i $(ANSIBLE_DIR)/inventory/hosts.ini --limit db --user $(ADMIN_USER) --private-key ~/.ssh/id_rsa $(ANSIBLE_DIR)/playbooks/setup-db.yml

	# Pass multiple inventory files using separate -i flags
	ansible-playbook -i $(ANSIBLE_DIR)/inventory/hosts.ini -i $(ANSIBLE_DIR)/inventory/azure_rm.yml --limit app_vmss --user $(ADMIN_USER) --private-key ~/.ssh/id_rsa --ssh-common-args='-o ProxyJump=$(ADMIN_USER)@$(BASTION_PUBLIC_IP)' $(ANSIBLE_DIR)/playbooks/deploy-app.yml

destroy:
	cd $(TF_DIR) && terraform destroy -auto-approve