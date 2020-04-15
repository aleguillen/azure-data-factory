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

RG_NAME="$PREFIX-$ENVIRONMENT-rg"
VNET_NAME="$PREFIX-$ENVIRONMENT-vnet"

##########################
### SCRIPT STARTS HERE ###
##########################

az login
az account set --subscription $SUBSCRIPTION_ID

# CREATE: Resource Group
az group create --name $RG_NAME --location $LOCATION

# CREATE: VNET
az network vnet create --name $VNET_NAME --resource-group $RG_NAME --address-prefix 10.0.0.0/16 --subnet-name default --subnet-prefix 10.0.0.0/24
