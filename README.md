# Azure Data Factory Examples using Terraform
Azure Data Factory


## Before you start

* Download and Install Terraform. 
    ** Hashicorp - Install Terraform: https://learn.hashicorp.com/terraform/azure/install_az
    ** Microsoft - Install and configure Terraform: https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure#install-terraform 

* Set up and configure Terraform access to Azure.
    ** To Set up account, go to this article: 
        > https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure#set-up-terraform-access-to-azure
    
* Clone repo in your local computer, for more info see [here](https://docs.microsoft.com/en-us/azure/devops/repos/git/clone).
    * Git source Url: https://github.com/aleguillen/azure-data-factory

## How to run [ADLS to SQL example](/adls-to-sql)

* Before you start, update variables values inside file *terraform.tfvars* located in */adls-to-sql/infra*.
* Navidate to the repo location in your local computer.
* Execute the following bash script:

    ```bash
    # Move to sample infra folder
    cd ./adls-to-sql/infra

    # Remember to Login to Azure
    # az login
    # az account set --subscription <replace-me-subscription-id>

    # Script to execute Terraform script - To perform: init, plan and apply select option 5
    ../../deploy.sh
    ```
