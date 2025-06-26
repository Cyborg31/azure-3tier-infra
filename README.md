# ☁️ 3-Tier Application on Azure with Terraform

This project automates the deployment of a fully functional, secure, and serverless **3-tier web application** architecture on **Microsoft Azure** using **Terraform**.

## 📦 Architecture Overview

The solution consists of:

- **Frontend**: Deployed using **Azure Static Web Apps**.
- **Backend**: Built on **Azure Linux Function Apps** (serverless).
- **Database**: Managed **Azure SQL Database** (PaaS).
- **Infrastructure**: Deployed securely using **Azure Key Vault**, **VNet**, **NSGs**, and **Subnets**.

## 🛠️ Technologies Used

- **Terraform** for infrastructure provisioning
- **Azure Static Web App** (Frontend)
- **Azure Linux Function App** (Backend)
- **Azure SQL Database**
- **Azure Key Vault** for secret management
- **Azure Virtual Network** with subnets and NSGs
- **Azure AD Service Principal** for secure automation

---

## 📁 Project Structure

terraform/
├── main.tf
├── providers.tf
├── network.tf
├── compute.tf
├── keyvault.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
└── README.md


---

## 🔐 Secrets Management

- **No secrets are hardcoded.**
- Secrets like SQL password, SP credentials, tenant ID, and subscription ID are securely stored in **Azure Key Vault**.
- A **Service Principal** is created and assigned the **Contributor** role, and its credentials are stored in the vault for CI/CD integration.

---

## 🚀 Deployment Steps

1. **Install Terraform CLI**
   ```bash
   brew install terraform  # macOS
   sudo apt install terraform  # Linux

    Clone this repo

git clone https://github.com/<your-org>/3tier-terraform-azure.git
cd 3tier-terraform-azure

Update terraform.tfvars

location            = "westus2"
resource_group_name = "my3tier-rg"
static_webapp_name  = "static-frontend"
...

Initialize Terraform

export environment variables if required
export ARM_SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
export ARM_TENANT_ID=$(az account show --query "tenantId" -o tsv)

terraform init

Review the execution plan

terraform plan

Apply the configuration

    terraform apply

    Output
    Terraform will print useful outputs:

        Static Web App URL

        Function App URL

        SQL Server FQDN

        Key Vault URI

✅ Benefits of This Architecture

    Fully serverless: No VM maintenance, scalable, and cost-effective.

    Secure: VNet isolation, NSGs, no public DB access, and Key Vault integration.

    Modular & reusable: Code is organized by concern (network, compute, secrets).

    Production-ready: Can be integrated with GitLab/GitHub CI/CD pipelines using stored credentials.

🧪 Next Steps / CI/CD Integration

To integrate with CI/CD:

    Retrieve Service Principal credentials from Key Vault.

    Use those in your pipeline to run Terraform plans and applies.