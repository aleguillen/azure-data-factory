
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
