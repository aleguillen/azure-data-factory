
# CREATE: Data Factory
resource "azurerm_data_factory" "example" {
  name                = local.df_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

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

resource "azurerm_role_assignment" "adf_to_adls_access" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.example.identity.0.principal_id
}

resource "azurerm_role_assignment" "adf_to_sql_access" {
  scope                = azurerm_sql_database.example.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.example.identity.0.principal_id
}
