# Azure Data Factory Example using Terraform
This repo shows an example on how to move data from Azure Data Lake Gen2 (csv file) to Azure SQL Server using Data Factory. Terraform is used as IaC tool for the infrastructure and Azure DevOps and Git Integration is used to implement a CI/CD lifecycle in an Azure Data Factory.

## Before you start

* Download and Install Terraform. 
    ** Hashicorp - Install Terraform: https://learn.hashicorp.com/terraform/azure/install_az
    ** Microsoft - Install and configure Terraform: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure#install-terraform 

* Set up and configure Terraform access to Azure.
    ** To Set up account, go to this article: 
        > https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure#set-up-terraform-access-to-azure
    
* Clone repo in your local computer, for more info see [here](https://docs.microsoft.com/en-us/azure/devops/repos/git/clone).
    * Git source Url: https://github.com/aleguillen/azure-data-factory

## How to create [infrastructure](/infra)

* Before you start, update variables values inside file *terraform.tfvars* located in */infra*.
* Navidate to the repo location in your local computer.
* Execute the following bash script:

    ```bash
    # Move to sample infra folder
    cd ./infra

    # Login to Azure
    az login
    az account set --subscription <replace-me-subscription-id>

    # init - Initialize a Terraform working directory
    terraform init

    # plan - Generate and show an execution plan
    terraform plan

    # apply -> Builds or changes infrastructure
    # -auto-approve -> optional - Skip interactive approval of plan before applying.
    terraform apply -auto-approve
    ```
