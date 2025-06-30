# Azure 3-Tier Web Application Deployment Using Terraform And Github Actions

## Project Overview

This project provides a comprehensive demonstration of a secure, scalable, and automated 3-tier web application deployed on Microsoft Azure. It leverages Infrastructure as Code (Terraform) for provisioning and **GitHub Actions** for streamlined Continuous Integration and Continuous Delivery (CI/CD).

The application serves as a foundational example where a simple web interface allows users to fetch and display data stored in an Azure SQL Database, with an Azure Function App acting as the intermediary API layer.

## Architecture

The application is logically separated into three distinct tiers, designed for maintainability and scalability:

1.  **Frontend (Presentation Layer):** A static web application built with HTML, CSS, and JavaScript. It is globally distributed and hosted on **Azure Static Web Apps**, providing high availability and fast content delivery via integrated CDN capabilities.
2.  **Backend (Application Logic Layer):** An **Azure Function App** (Python-based) acts as a serverless API. It securely handles incoming requests from the frontend, processes business logic, and interacts with the database. The Function App runs on a **Premium Plan (EP1)**, offering dedicated resources for minimal cold starts and enabling Virtual Network integration.
3.  **Database (Data Layer):** An **Azure SQL Database** stores the application's persistent data.

**Key Architectural Highlights:**

* **Secure Database Connectivity:** The Azure Function App connects to the Azure SQL Database through a **Virtual Network (VNet) Integration** and a **Private Endpoint**. This design ensures all database traffic remains private within your Azure VNet, enhancing security by preventing exposure over the public internet.
* **Serverless Efficiency:** Azure Functions provide a pay-per-execution model, automatically scaling with demand, ideal for event-driven API backends. The Premium Plan ensures consistent performance.
* **Global Frontend Delivery:** Azure Static Web Apps automatically integrate with Azure CDN, delivering your frontend content efficiently to users worldwide.
* **Infrastructure as Code (IaC):** The entire Azure infrastructure (resource groups, static web app, function app, SQL database, networking, Key Vault, etc.) is defined and provisioned using **HashiCorp Terraform**, ensuring consistency, repeatability, and version control for your cloud resources.
* **Automated CI/CD with GitHub Actions:** All infrastructure provisioning and application code deployments are orchestrated automatically via GitHub Actions workflows, ensuring a seamless and reliable deployment pipeline on every code push.

### Architectural Diagram

Here's a visual representation of the application's architecture:

```mermaid
graph TD
    subgraph User Interaction
        A[User / Browser] -- HTTPS Request --> B(Azure Static Web App\nFrontend)
    end

    subgraph Presentation Tier
        B -- API Call (HTTPS / CORS) --> C[Azure Function App\nBackend API]
    end

    subgraph Application Tier
        C -- VNet Integration --> D{Azure Virtual Network\nPrivate Subnet}
        D -- Private Link Connection --> E[Azure SQL Database\nData Layer]
        C -- Reads Secret --> F(Azure Key Vault\nSecure Credentials)
    end

    style A fill:#f0f9ff,stroke:#0078D4,stroke-width:2px;
    style B fill:#e0f7fa,stroke:#0078D4,stroke-width:2px;
    style C fill:#e0f7fa,stroke:#0078D4,stroke-width:2px;
    style D fill:#f9fbe7,stroke:#0078D4,stroke-width:2px;
    style E fill:#f3e5f5,stroke:#0078D4,stroke-width:2px;
    style F fill:#fff3e0,stroke:#0078D4,stroke-width:2px;

    linkStyle 0 stroke:#333,stroke-width:2px;
    linkStyle 1 stroke:#333,stroke-width:2px;
    linkStyle 2 stroke:#333,stroke-width:2px;
    linkStyle 3 stroke:#333,stroke-width:2px;
    linkStyle 4 stroke:#333,stroke-width:2px;

## Features

* **Dynamic Data Display:** Frontend fetches and displays data from the Azure SQL Database via the backend API.
* **Full Automation:** Infrastructure provisioning and application deployment fully automated via GitHub Actions.
* **Enhanced Security:** Private network communication for database access and centralized secrets management.
* **Optimized Performance:** Serverless backend with premium capabilities.
* **Centralized Secrets Management:** Sensitive information (like database credentials, API keys) are stored and retrieved securely from Azure Key Vault.

## Technologies Used

* **Cloud Provider:** Microsoft Azure
* **Infrastructure as Code:** HashiCorp Terraform
* **Automation:** GitHub Actions
* **Frontend:** HTML, CSS, JavaScript (deployed to Azure Static Web Apps)
* **Backend:** Python (deployed as Azure Function App)
* **Database:** Azure SQL Database
* **Networking:** Azure Virtual Network, Private Endpoints, Private DNS Zones
* **Security:** Azure Key Vault, Managed Identities

## Prerequisites

Before you begin, ensure you have the following installed and configured on your local machine for local development and initial setup:

* **Git:** For cloning the repository.
* **Azure CLI:**
    * Installed and authenticated (`az login`) to the Azure subscription where you want to deploy resources.
    * Ensure the correct subscription is set: `az account set --subscription "Your Subscription Name or ID"`
* **Terraform (v1.4.0+):** [Download & Install](https://www.terraform.io/downloads.html) - Needed for local `terraform destroy` or manual `terraform apply`.
* **Azure Functions Core Tools (v4.x):**
    * Requires Node.js and npm. Install globally: `npm install -g azure-functions-core-tools@4 --unsafe-perm true`
* **Python 3.10+:** Ensure `python3` is in your system's PATH.

## Project Setup

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/your-username/azure-3tier-infra.git](https://github.com/your-username/azure-3tier-infra.git) # Replace with your actual repo URL
    cd azure-3tier-infra
    ```

2.  **Azure Authentication (if not already done):**
    Ensure your Azure CLI is logged in and pointing to the correct subscription. GitHub Actions will handle authentication automatically using OpenID Connect (OIDC) or service principals for deployments.
    ```bash
    az login
    export ARM_SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
    export ARM_TENANT_ID=$(az account show --query "tenantId" -o tsv)
    ```

## Automated Deployment Workflow

This project leverages GitHub Actions for automated CI/CD. Deployments are triggered automatically based on code changes:

* **Infrastructure (Terraform):**
    * Pushing changes to the `terraform/` directory (e.g., to the `main` branch) will trigger a workflow to `terraform apply` your infrastructure changes.
    * It's recommended to set up a separate workflow for Pull Requests that performs `terraform plan` to review infrastructure changes before merging.
* **Frontend & Backend Code:**
    * Pushing new code to the `main` branch (or configured deployment branches) in `app/frontend/` or `app/backend/` will automatically trigger their respective deployment workflows.

**To initiate the first full deployment:**

1.  Ensure your GitHub repository has the necessary **GitHub Actions secrets and/or OIDC configuration** for Azure authentication (e.g., `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` if using service principal, or OIDC setup).
2.  Push your initial codebase (including the `.github/workflows` directory) to your `main` branch.
3.  Monitor the "Actions" tab in your GitHub repository to observe the deployment workflows running.

## Post-Deployment & Usage

After a successful deployment via GitHub Actions:

1.  **Retrieve Application URLs (from your local machine):**
    You can get the URLs using Terraform's output commands (ensure you've run `terraform init` and `terraform apply` at least once locally, or `terraform output` if state is configured remotely).
    ```bash
    # Ensure you are in the 'terraform' directory for these commands
    cd terraform

    echo "Static Web App URL: $(terraform output -raw static_web_app_url)"
    echo "Function App URL:   $(terraform output -raw function_app_url)"

    cd .. # Go back to root
    ```

2.  **Access the Frontend:**
    Open the Azure Static Web App URL (e.g., `https://green-moss-0dae2121e.1.azurestaticapps.net/`) in your web browser.

3.  **Initialize Database (First-time / Data Reset):**
    *If your database is empty or you wish to re-populate it with sample data, you'll need to trigger the `init-db` function.*
    The `init-db` function is secured with an API key stored in Azure Key Vault.

    First, get the necessary dynamic values (from your local machine):
    ```bash
    # Get resource group name (assuming you have a terraform output for it)
    RESOURCE_GROUP_NAME=$(cd terraform && terraform output -raw resource_group_name && cd ..)
    FUNCTION_APP_NAME=$(cd terraform && terraform output -raw function_app_name && cd ..)

    ADMIN_API_KEY=$(az keyvault secret show --name admin-api-key --vault-name ${RESOURCE_GROUP_NAME}-kv --query value -o tsv)
    FUNC_APP_URL=$(az functionapp show --name ${FUNCTION_APP_NAME} --resource-group ${RESOURCE_GROUP_NAME} --query "defaultHostName" -o tsv)
    ENCODED_KEY=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote_plus(sys.argv[1]))" "$ADMIN_API_KEY")
    ```
    Then, trigger the `init-db` function:
    ```bash
    curl -v "https://${FUNC_APP_URL}/api/init-db?code=${ENCODED_KEY}"
    ```
    *You should see a success message in the terminal if the database was initialized.*

4.  **Fetch Data:**
    * **Via Frontend:** On the deployed Static Web App page, click the **"Fetch Data" button**. You should see the sample data appear below the button.
    * **Direct Backend Test (Optional):** You can also test the `getdata` function directly using `curl` (note that the `getdata` function requires an `x-functions-key` header for security, which your frontend automatically adds).
        ```bash
        # Get resource group name (assuming you have a terraform output for it)
        RESOURCE_GROUP_NAME=$(cd terraform && terraform output -raw resource_group_name && cd ..)
        FUNCTION_APP_NAME=$(cd terraform && terraform output -raw function_app_name && cd ..)

        GETDATA_API_KEY=$(az functionapp function keys list --function-name getdata --name ${FUNCTION_APP_NAME} --resource-group ${RESOURCE_GROUP_NAME} --query "default" -o tsv)
        FUNC_APP_URL=$(az functionapp show --name ${FUNCTION_APP_NAME} --resource-group ${RESOURCE_GROUP_NAME} --query "defaultHostName" -o tsv)
        
        curl -v -H "x-functions-key: ${GETDATA_API_KEY}" "https://${FUNC_APP_URL}/api/getdata"
        ```

## Cleanup

To destroy all Azure resources provisioned by Terraform:

```bash
# Navigate to the terraform directory
cd terraform

# Run terraform destroy
terraform destroy

# Go back to the root directory
cd ..

Warning: This command will permanently delete all associated Azure resources and their data. Use with extreme caution.