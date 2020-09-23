output "sql_id" {
  value = azurerm_sql_database.example.id
}

output "data_lake_id" {
  value = azurerm_storage_account.example.id
}

output "key_vault_id" {
  value = azurerm_key_vault.example.id
}

output "azurerm_client_config" {
  value = data.azurerm_client_config.current
}

output "adf_self_hosted_key1" {
  value = azurerm_data_factory_integration_runtime_self_hosted.example.auth_key_1
}