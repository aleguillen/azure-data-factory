# CREATE: Data Factory
resource "azurerm_data_factory" "example" {
  name                = local.df_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Enable Managed Identity
  identity {
    type = "SystemAssigned"
  }

  dynamic "github_configuration" {
    for_each = local.df_github_configuration

    content {
      account_name    = github_configuration.value["account_name"]
      branch_name     = github_configuration.value["branch_name"]
      git_url         = github_configuration.value["git_url"]
      repository_name = github_configuration.value["repository_name"]
      root_folder     = github_configuration.value["root_folder"]
    }
  }

  tags = merge(
    local.common_tags,
    {
      display_name = "Data Factory"
    }
  )

}

# CREATE: Data Factory IR
resource "azurerm_data_factory_integration_runtime_self_hosted" "example" {
  name                = "shir-${azurerm_data_factory.example.name}"
  resource_group_name = azurerm_resource_group.example.name
  data_factory_name   = azurerm_data_factory.example.name
}

# UPDATE: Adding Access Policy for Azure Data Factory
resource "azurerm_key_vault_access_policy" "data_factory" {

  key_vault_id = azurerm_key_vault.example.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_data_factory.example.identity.0.principal_id

  secret_permissions = [
    "get",
    "list"
  ]
}
