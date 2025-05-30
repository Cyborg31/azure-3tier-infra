# 🚀 Azure 3-Tier Infra Deployment (Terraform + Ansible)

This project automates the secure deployment of a 3-tier infrastructure on Azure using **Terraform**, **Ansible**, and a **Makefile**.

## ✅ Features

- Infrastructure with Terraform
- Secrets via Azure Key Vault (no hardcoding)
- Ansible deployment with dynamic inventory
- SSH via Bastion → Jumpbox → Internal VMs
- One command deployment with `make all`
- Modular, scalable, and cloud-ready

🏗️ Architecture Overview

This project implements a secure, scalable 3-tier web application architecture on Azure, fully automated using Terraform, Ansible, and a Makefile-based pipeline.

🔐 Security & Access

    Azure Bastion: Provides secure browser-based access to the Jumpbox VM from the Azure Portal without exposing public IPs on internal VMs.

    Jumpbox VM: Acts as a secure SSH gateway into the private infrastructure (App and DB tiers). Accessible via Azure Bastion only.

🌐 Network Layout

    Virtual Network with five subnets:

        Web Subnet (Public): Hosts the web frontend behind a public load balancer.

        App Subnet (Private): Hosts backend application servers behind a private load balancer.

        DB Subnet (Private): Hosts MySQL database VM.

        Jumpbox Subnet: Hosts the Jumpbox VM for internal SSH access.

        AzureBastionSubnet: Required subnet for Azure Bastion.

⚙️ Automation Pipeline

    Terraform provisions the entire Azure infrastructure including VMs, subnets, NSGs, load balancers, and Azure Bastion.

    Makefile orchestrates Terraform, dynamic inventory generation, and Ansible deployment.

    Ansible installs required packages, configures servers, and deploys the frontend/backend code to the VMs.

📦 Application

    Frontend (Web Tier): Node.js app served via Nginx, accessible over the internet.

    Backend (App Tier): Node.js API served privately, only reachable from the Web tier.

    Database (DB Tier): MySQL, accessible only from the App tier.

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