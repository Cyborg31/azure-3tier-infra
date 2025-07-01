Azure 3-Tier Web App Deployment with Terraform & GitHub Actions
Overview

This project automates deployment of a secure, scalable 3-tier web app on Azure using Terraform and GitHub Actions CI/CD.

    Frontend: Static Web App (HTML/JS)

    Backend: Python Azure Function App (serverless API)

    Database: Azure SQL Database

The backend securely connects to the database via private networking, while the frontend fetches data through the API.
Architecture Highlights

    Infrastructure as Code with Terraform

    Automated CI/CD with GitHub Actions

    Private VNet and Private Endpoint for DB security

    Azure Key Vault for secrets management

    Serverless backend on Premium Plan for performance

Quick Start

    Clone repo

git clone https://github.com/Cyborg31/azure-3tier-infra
cd azure-3tier-infra

Authenticate Azure CLI

    az login
    az account set --subscription "<your-subscription>"

    Deploy infrastructure and app via GitHub Actions on push to main branch.

Cleanup

To destroy all resources:

cd terraform
terraform destroy -auto-approve
cd ..