# Azure Serverless Microservice [WIP]

Azure serverless demo highlighting key functionalities of Azure Functions, API Managements, and Logic App.

## Pre-requisite

- [Terraform](https://www.terraform.io/downloads.html)
- [Postman](https://www.getpostman.com/downloads/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [VS Code](https://code.visualstudio.com/download)
  - [VS Code: Azure Function Tutorial](https://code.visualstudio.com/tutorials/functions-extension/getting-started)

## Getting Started

- Clone the repository

- In `./terraform`:
  - Change `prefix` in `variables.tf` because Azure Storage and Azure Function names has to be globally unique
    - For the remainder of the documentation, the prefix `azure-serverless` **WILL BE ASSUMED**
  - Run `terraform init` to initialize Terraform
  - Run `terraform plan -out=out.tfplan`
  - Run `terraform apply out.tfplan`
  - Note the outputs of `terraform apply`

- To leverage GitHub Actions to continuous integrate & deploy Azure Functions, you have to add application settings to Azure Functions before deployment
  - Save Azure Cosmos DB primary connection string for later use
  - Create a new connection string entry with key `CosmosDBConnection` and value of Azure CosmosDB primary connection string (from above) in Azure Functions application settings (under `azure-serverless-func` -> "Configuration")

- To configure GitHub Actions with Azure, take the below steps
  - Follow steps [here](https://github.com/marketplace/actions/azure-functions-action#using-publish-profile-as-deployment-credential)

- For local development, use [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=linux) to test Azure Functions locally

- In `functions/`,
  - Run `func extensions install` to install Azure Functions extensions required to run the demo. This may require installation of other dependencies such as `dotnet`

## Considerations

- To use linked template, you can only provide a URI value that includes either http or https ([ref](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/linked-templates#linked-template)). You can't specify a local file or a file that is only available on your local network.

- Although the linked template must be externally available, it doesn't need to be generally available to the public. You can add your template to a private storage account that is accessible to only the storage account owner. Then, you create a shared access signature (SAS) token to enable access during deployment ([ref](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/linked-templates#securing-an-external-template)).

- Use type `securestring` for secrets, keys, and connection strings

- Instead of putting a secure value (like a password) directly in your template or parameter file, you can retrieve the value from an Azure Key Vault during a deployment. You retrieve the value by referencing the key vault and secret in your parameter file. The value is never exposed because you only reference its key vault ID ([ref](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/key-vault-parameter?tabs=azure-cli)).

## References

- [Azure Functions Python developer guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python)
- [Azure Functions Python samples](https://github.com/yokawasa/azure-functions-python-samples/blob/master/v2functions/cosmos-trigger-cosmodb-output-binding/__init__.py)
- [Azure Resource Manager (ARM) template best practice](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-best-practices)

## Next Steps

- [] IaC in TF or ARM (Azure Function, Azure CosmosDB)
- [] abstract configurations into app settings (https://docs.microsoft.com/en-us/azure/azure-functions/functions-how-to-use-azure-function-app-settings)
- [] test function CI/CD
- [] use azure app configuration
- [] Demo Azure Function in JS
- [] Logic App Integration
- [] Event hub integration
- [] CI/CD
- [] Telemetry
- [] API management
- [] Alerts & Notification
- [] DR

---

### PLEASE NOTE FOR THE ENTIRETY OF THIS REPOSITORY AND ALL ASSETS

1. No warranties or guarantees are made or implied.
2. All assets here are provided by me "as is". Use at your own risk. Validate before use.
3. I am not representing my employer with these assets, and my employer assumes no liability whatsoever, and will not provide support, for any use of these assets.
4. Use of the assets in this repo in your Azure environment may or will incur Azure usage and charges. You are completely responsible for monitoring and managing your Azure usage.

---

Unless otherwise noted, all assets here are authored by me. Feel free to examine, learn from, comment, and re-use (subject to the above) as needed and without intellectual property restrictions.

If anything here helps you, attribution and/or a quick note is much appreciated.
