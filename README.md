## Description

- Project created to train Terraform and deployment of various different services in Azure. Used to create azure storage account, hub and spoke topology, network security groups with ingress rules and Kubernetes cluster with Azure DevOps.
- Key objectives:
    - Create multiple Terraform modules
    - Create Azure DevOps Pipeline to trigger on changes in GitHub repository to provision and deploy developed code
- Resources used for study:
    - [Julie Ng youtube channel](https://www.youtube.com/c/JulieNgTech/videos)
    - [Les Jackson youtube channel](https://www.youtube.com/c/binarythistle/videos)
    - [That DevOps Guy youtube channel](https://www.youtube.com/c/MarcelDempers/videos)
    - [Course Terraform on Azure (2021) on INE](https://my.ine.com/Cloud/courses/96153df6/terraform-on-azure-2021)

## Requirements

- Install [Visual Studio Code](https://code.visualstudio.com/download) (VSC)
- Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and add [extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform) to VSC
- Project in [GitHub](https://github.com/join)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) package
- [Storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal) in Azure to store Terraform state file remotely
- [Service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals) in Azure with [role assignment](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-steps) for Terraform
- [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/quick-create-portal) to store your secrets
    - [Store your secrets](https://docs.microsoft.com/en-us/azure/key-vault/secrets/quick-create-portal#add-a-secret-to-key-vault) in Azure Key Vault
    - [Tenant ID](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant), [Subscription ID, Client ID, Client Secret](https://www.cloudsnooze.com/news/view/29), [Storage Key](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-keys-manage?tabs=azure-portal#view-account-access-keys)

## Terraform Modules

- Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) and add [extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform) to VSC
- [Store your secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform) as variables to use them locally
    
    ```
    export ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"
    export ARM_TENANT_ID="<YOUR_TENANT_ID>"
    export ARM_CLIENT_ID="<YOUR_CLIENT_ID>"
    export ARM_CLIENT_SECRET="<YOUR_CLIENT_SECRET>"
    ```
    
- Create [backed configuration file](https://www.terraform.io/language/settings/backends/azurerm#example-configuration) to store TF state file remotely
    
    ```
    storage_account_name="<your storage account name>"
    container_name="<your container name>"
    key="<your TF state file name>"
    access_key="<your access key>"
    ```
    
    - You can also uses [SAS token](https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview) (preferable) and backend configuration file needs to be added to git ignore
- Create your [Terraform file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) and define required providers
    
    ```
    terraform {
      backend "azure" {
      }
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "=3.0.0"
        }
      }
    }
    
    provider "azurerm" {
      features {}
    }
    ```
    
    - [Resource group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) to hold all the resources
    - [Module to create Storage account](https://registry.terraform.io/modules/kumarvna/storage/azurerm/latest)
    - [Virtual Networks and subnets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) for Hub and Spoke topology
    - [Virtual Network peering](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) to build topology
    - [Kubernetes Cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
    - [Kubernetes deployment](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment)
- Generate SSH key
    
    ```
    ssh-keygen -t rsa -b 4096 -N "VeryStrongSecret123!" -C "your_email@example.com" -q -f  ~/.ssh/id_rsa
    ```
    
    - Save it as variable
        
        ```
        SSH_KEY=$(cat ~/.ssh/id_rsa.pub)
        ```
        
    - Store your SSH key to Key Vault
        
        ```
        echo $SSH_KEY
        ```
        
- To run Terraform locally
    
    ```
    terraform init -backed-config <backend configuration file>
    ```
    
    ```
    terraform plan -var serviceprinciple_id=$ARM_SERVICE_PRINCIPAL \
        -var serviceprinciple_key="$ARM_SERVICE_PRINCIPAL_SECRET" \
        -var tenant_id=$ARM_TENTANT_ID \
        -var subscription_id=$ARM_SUBSCRIPTION \
        -var ssh_key="$SSH_KEY"
    ```
    
    ```
    terraform apply -var serviceprinciple_id=$ARM_SERVICE_PRINCIPAL \
        -var serviceprinciple_key="$ARM_SERVICE_PRINCIPAL_SECRET" \
        -var tenant_id=$ARM_TENTANT_ID \
        -var subscription_id=$ARM_SUBSCRIPTION \
        -var ssh_key="$SSH_KEY"
    ```
    

## Azure DevOps Pipeline

- Create private [Azure DevOps project](https://docs.microsoft.com/en-us/azure/devops/organizations/projects/create-project?view=azure-devops&tabs=browser)
    - Initialize Azure DevOps repo from existing repository in GitHub
- Create Azure and GitHub [service connections](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) in Azure DevOps
- Integrate [Azure Key Vault with Azure Pipelines](https://thomasthornton.cloud/2021/06/24/storing-and-retrieving-secrets-in-azure-keyvault-with-variable-groups-in-azure-devops-pipelines/) to retrieve secrets in your pipelines
- Create your [pipeline with GitHub](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops&tabs=yaml) to build Azure infrastructure via [Terraform](https://learn.hashicorp.com/tutorials/terraform/automate-terraform)
