# 🚀 Azure 3-Tier Infra Deployment (Terraform + Ansible)

This project automates the secure deployment of a 3-tier infrastructure on Azure using **Terraform**, **Ansible**, and a **Makefile**.

## ✅ Features

- Infrastructure with Terraform
- Secrets via Azure Key Vault (no hardcoding)
- Ansible deployment with dynamic inventory
- SSH via Bastion → Jumpbox → Internal VMs
- One command deployment with `make all`
- Modular, scalable, and cloud-ready

## 🔧 Prerequisites

- Azure CLI  
- Terraform  
- Ansible  
- Bash shell (WSL/Ubuntu)  
- SSH key (`~/.ssh/id_rsa`)

## 🛠️ Quick Setup

```bash
git clone https://github.com/Cyborg31/azure-3tier-infra.git
cd azure-3tier-infra

ssh-keygen -t rsa -b 4096 -C "your_email@example.com"  # if not done

make all  # provisions infra and deploys app
```

🧹 Cleanup

```bash
make clean
```

📁 Structure

- terraform/ – Infra as code
- ansible/ – Playbooks and inventory
- Makefile – Full automation
- README.md – Docs

👨‍💻 Author

Sudip Giri | 📧 sudeepgiri31@gmail.com | 📍 Toronto

Created as a secure cloud infrastructure automation project for learning.