#!/bin/bash

################################################################################################################
## This script is to create Bastion network to showcase an On-prem environment.                               ##
## The name Bastion network comes from Azure Bastion since is enabled on test VM located in the same network. ##
################################################################################################################


#################
### VARIABLES ###
#################
SUBSCRIPTION_ID=<replace-me>

PREFIX=<replace-me>
ENVIRONMENT=<replace-me>
LOCATION=<replace-me>

RG_NAME="rg-$PREFIX-$LOCATION-$ENVIRONMENT"
VNET_NAME="vnet-$PREFIX-$ENVIRONMENT"
VM_NAME="vm-$PREFIX-$ENVIRONMENT"
CREATE_DFIR_VM=false
VM_NAME_WS="vm-dfir-$ENVIRONMENT"
BASTION_HOST="bastion-$PREFIX-$ENVIRONMENT"
BASTION_HOST_PIP="pip-bastion-$PREFIX-$ENVIRONMENT"

SUBNET_NAME="default"

##########################
### SCRIPT STARTS HERE ###
##########################

az login
az account set --subscription $SUBSCRIPTION_ID

# CREATE: Resource Group
az group create --name $RG_NAME --location $LOCATION

# CREATE: VNET and SUBNETS
az network vnet create --name $VNET_NAME --resource-group $RG_NAME --address-prefix 10.0.0.0/16 
az network vnet subnet create --name $SUBNET_NAME --vnet-name $VNET_NAME --resource-group $RG_NAME --address-prefixes 10.0.0.0/24
az network vnet subnet create --name "AzureBastionSubnet" --vnet-name $VNET_NAME --resource-group $RG_NAME --address-prefixes 10.0.1.0/27
az network vnet subnet create --name "datafactory" --vnet-name $VNET_NAME --resource-group $RG_NAME --address-prefixes 10.0.1.32/29

az network vnet subnet update --name $SUBNET_NAME \
    --vnet-name $VNET_NAME \
    --resource-group $RG_NAME \
    --disable-private-endpoint-network-policies true \
    --disable-private-link-service-network-policies true

# CREATE: Azure Bastion Host
az network public-ip create --name $BASTION_HOST_PIP --resource-group $RG_NAME --sku Standard

az network bastion create --name $BASTION_HOST \
--public-ip-address $BASTION_HOST_PIP \
--resource-group $RG_NAME \
--vnet-name $VNET_NAME \
--location $LOCATION

# CREATE: Linux Server
az vm create \
    --resource-group $RG_NAME \
    --name $VM_NAME \
    --image Canonical:UbuntuServer:18.04-LTS:latest \
    --storage-sku StandardSSD_LRS \
    --size Standard_D2_v3 \
    --admin-username azureuser \
    --generate-ssh-keys \
    --vnet-name $VNET_NAME \
    --subnet "default"

# CREATE: Windows Server - Data Factory IR
# You will be prompt to enter password
`if [ "$CREATE_DFIR_VM" = true ]; 
then
echo "Creating Data Factory IR Server - $RG_NAME - $VM_NAME_WS"
az vm create \
    --resource-group $RG_NAME \
    --name $VM_NAME_WS \
    --image win2016datacenter \
    --storage-sku StandardSSD_LRS \
    --size Standard_D2_v3 \
    --admin-username azureuser \
    --vnet-name $VNET_NAME \
    --subnet "datafactory"
fi

echo "private_link_resource_group_name = \"$RG_NAME\""
echo "private_link_vnet_name = \"$VNET_NAME\""
echo "private_link_subnet_name = \"$SUBNET_NAME\""
`