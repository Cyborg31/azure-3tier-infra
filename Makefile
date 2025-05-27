# Variables
TERRAFORM_DIR = terraform
ANSIBLE_DIR = ansible
INVENTORY_FILE = $(ANSIBLE_DIR)/inventory/hosts.ini

.PHONY: all terraform generate-inventory ansible clean

# Run everything
all: terraform generate-inventory ansible

# Terraform provisioning
terraform:
	cd $(TERRAFORM_DIR) && terraform init
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

# Generate Ansible inventory from Terraform outputs

generate-inventory:
	@echo "Generating Ansible inventory..."

	# Clean old temp files
	@rm -f /tmp/jumpbox_ip /tmp/db_ip /tmp/admin /tmp/web_lb_ip /tmp/app_lb_ip /tmp/bastion_ip

	# Fetch Terraform outputs
	@cd $(TERRAFORM_DIR) && terraform output -raw jumpbox_private_ip > /tmp/jumpbox_ip
	@cd $(TERRAFORM_DIR) && terraform output -raw db_private_ip > /tmp/db_ip
	@cd $(TERRAFORM_DIR) && terraform output -raw admin_username > /tmp/admin
	@cd $(TERRAFORM_DIR) && terraform output -raw web_lb_public_ip > /tmp/web_lb_ip
	@cd $(TERRAFORM_DIR) && terraform output -raw app_lb_private_ip > /tmp/app_lb_ip
	@cd $(TERRAFORM_DIR) && terraform output -raw bastion_public_ip > /tmp/bastion_ip

	# Store vars and write inventory file in the same shell
	@admin=$$(cat /tmp/admin); \
	bastion_ip=$$(cat /tmp/bastion_ip); \
	jumpbox_ip=$$(cat /tmp/jumpbox_ip); \
	db_ip=$$(cat /tmp/db_ip); \
	web_lb_ip=$$(cat /tmp/web_lb_ip); \
	app_lb_ip=$$(cat /tmp/app_lb_ip); \
	echo "[bastion]" > $(INVENTORY_FILE); \
	echo "bastion ansible_host=$$bastion_ip ansible_user=$$admin ansible_ssh_private_key_file=~/.ssh/id_rsa" >> $(INVENTORY_FILE); \
	echo "[jumpbox]" >> $(INVENTORY_FILE); \
	echo "jumpbox ansible_host=$$jumpbox_ip ansible_user=$$admin ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_common_args='-o ProxyJump=$$admin@$$bastion_ip'" >> $(INVENTORY_FILE); \
	echo "[db]" >> $(INVENTORY_FILE); \
	echo "db1 ansible_host=$$db_ip ansible_user=$$admin ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_common_args='-o ProxyJump=$$admin@$$bastion_ip,$$admin@$$jumpbox_ip'" >> $(INVENTORY_FILE); \
	echo "[web_loadbalancer]" >> $(INVENTORY_FILE); \
	echo "weblb ansible_host=$$web_lb_ip ansible_user=$$admin ansible_ssh_private_key_file=~/.ssh/id_rsa" >> $(INVENTORY_FILE); \
	echo "[app_loadbalancer]" >> $(INVENTORY_FILE); \
	echo "applb ansible_host=$$app_lb_ip ansible_user=$$admin ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_common_args='-o ProxyJump=$$admin@$$bastion_ip'" >> $(INVENTORY_FILE)

# Run Ansible deployment
ansible:
	@cd $(ANSIBLE_DIR) && ansible-playbook playbooks/deploy.yml

# Destroy infrastructure and clean files
clean:
	rm -f /tmp/jumpbox_ip /tmp/db_ip /tmp/admin /tmp/web_lb_ip /tmp/app_lb_ip /tmp/bastion_ip
	rm -f $(INVENTORY_FILE)
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve