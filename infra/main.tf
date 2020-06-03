terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  version = "= 2.11"
  features {}
}

data "azurerm_client_config" "current" {}

# Create Resource Group
resource "azurerm_resource_group" "example" {
  name     = local.rg_name
  location = var.location

  tags = merge(
    local.common_tags,
    {
      created      = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
      display_name = "Data Factory Resource Group"
    }
  )

  lifecycle {
    ignore_changes = [
      tags["created"],
    ]
  }
}