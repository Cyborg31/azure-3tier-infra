# Azure 3-Tier Web Application Deployment using Terraform

## Project Overview

This project demonstrates a simple yet robust 3-tier web application deployed on Microsoft Azure using Infrastructure as Code (Terraform) and automated with Makefiles. The application showcases fundamental cloud architecture principles, secure networking practices, and automated deployment pipelines.

The core functionality is a basic web page that, upon a button click, fetches data from an Azure SQL Database via an Azure Function App and displays it to the user.

## Architecture

The application is structured into three logical tiers:

1.  **Frontend (Presentation Layer):** A static web application hosted on Azure Static Web Apps. It's built with plain HTML, CSS, and JavaScript.
2.  **Backend (Application Logic Layer):** An Azure Function App (Python) that serves as a simple API. It handles requests from the frontend, queries the database, and returns the data.
3.  **Database (Data Layer):** An Azure SQL Database that stores the application's data.

**Key Architectural Highlights:**

* **Secure Database Connectivity:** The Azure Function App securely connects to the Azure SQL Database using **Virtual Network (VNet) Integration** and a Private Endpoint for the database. This ensures that database traffic remains entirely within your private Azure network, avoiding the public internet.
* **Serverless Backend:** The Azure Function App runs on a **Premium Plan (EP1)**, providing VNet integration, dedicated resources, and eliminating cold starts for a responsive API.
* **Global Frontend Delivery:** Azure Static Web Apps provide global content delivery network (CDN) capabilities for fast and reliable frontend access.
* **Infrastructure as Code (IaC):** All Azure resources are provisioned and managed using HashiCorp Terraform, ensuring consistent and repeatable deployments.
* **Automated Deployment:** A `Makefile` orchestrates the entire deployment process, from infrastructure provisioning to application code deployment for both frontend and backend.

## Features

* Displays data from a backend database on a button click.
* Fully automated infrastructure provisioning and application deployment.
* Secure and isolated network communication between application tiers.
* Serverless backend with optimized performance.

## Technologies Used

* **Cloud Provider:** Microsoft Azure
* **Infrastructure as Code:** HashiCorp Terraform
* **Automation:** GNU Make
* **Frontend:** HTML, CSS, JavaScript (Static Web App)
* **Backend:** Python (Azure Functions)
* **Database:** Azure SQL Database

## Prerequisites

Before deploying this project, ensure you have the following installed and configured on your local machine:

* **Git:** For cloning the repository.
* **Azure CLI:** Authenticated (`az login`) to the Azure subscription where you want to deploy resources, and the correct subscription is set (`az account set --subscription "Your Subscription Name or ID"`).
* **Terraform (v1.0.0+):** [Download & Install](https://www.terraform.io/downloads.html)
* **Azure Functions Core Tools (v4.x):** Install globally via npm: `npm install -g azure-functions-core-tools@4 --unsafe-perm true`
* **Python 3.x:** (e.g., Python 3.9+) Ensure `python3` is in your system's PATH.
* **`make` utility:** (Usually pre-installed on Linux/macOS. For Windows, use WSL or Git Bash).

## Project Setup

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/your-username/azure-3tier-infra.git](https://github.com/your-username/azure-3tier-infra.git)
    cd azure-3tier-infra
    az login
    export ARM_SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
    export ARM_TENANT_ID=$(az account show --query "tenantId" -o tsv)
    ```
    ```

## Deployment Steps

All deployment steps are automated via the `Makefile`. Run these commands from the root of your `azure-3tier-infra` directory.

1.  **Full Deployment (Infrastructure, Frontend, Backend):**
    This command will provision all Azure resources, set up the Python virtual environment, install backend dependencies, deploy the frontend, and deploy the backend.

    ```bash
    make all
    ```
    *This is the recommended command for initial setup.*

2.  **Deploy Infrastructure Only:**
    Provisions or updates Azure resources defined in Terraform.
    ```bash
    make infra
    ```

3.  **Deploy Frontend Only:**
    Deploys the static HTML/CSS/JS to Azure Static Web Apps.
    ```bash
    make frontend
    ```

4.  **Deploy Backend Only:**
    Sets up the Python virtual environment (if not already done) and deploys the Azure Function App.
    ```bash
    make backend
    ```

## Post-Deployment & Usage

After successful deployment (especially `make all`), you can retrieve the application URLs:

```bash
make show_urls

This will output the URL for your Azure Static Web App (frontend) and your Azure Function App (backend).

    Open the Static Web App URL in your web browser.

    Click the button on the page to fetch data from your backend Function App.

Cleanup

To destroy all Azure resources provisioned by Terraform:
Bash

make destroy

Warning: This command will permanently delete all associated Azure resources and their data. Use with caution.

To clean up local build artifacts and the Python virtual environment:
Bash

make clean

API_KEY=$(az keyvault secret show --name admin-api-key --vault-name my-three-tier-rg-kv --query value -o tsv)
ENCODED_KEY=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$API_KEY")
curl -v "https://backend-func-3tier.azurewebsites.net/api/init-db?key=$ENCODED_KEY"

API_KEY=$(az keyvault secret show --name admin-api-key --vault-name my-three-tier-rg-kv --query value -o tsv)
ENCODED_KEY=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$API_KEY")
curl "https://backend-func-3tier.azurewebsites.net/api/getdata?key=$ENCODED_KEY"

