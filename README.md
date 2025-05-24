# Azure 3-Tier Application infrastructure Deployment with Terraform 

This project automates the secure deployment of a 3-tier infrastructure on Microsoft Azure using **Terraform**. It uses SSH key for secure access, and avoids hardcoded secrets via Azure Key Vault.

- Provision Azure infrastructure using Terraform
- Uses Azure Key Vault to secure credentials
- Modular, scalable, and cloud-ready

## 🔧 Prerequisites

- Azure CLI
- Terraform
- Bash shell (via WSL/Ubuntu on Windows)

## 🛠️ Setup

### 1. Clone the repository

git clone https://github.com/Cyborg31/azure-3tier-infra.git
cd azure-3tier-infra

2. Generate SSH key (if not done)

ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

⚙️ Run terraform Script

terraform init
terraform plan
terraform apply



Created as a secure cloud infrastructure automation project for learning.