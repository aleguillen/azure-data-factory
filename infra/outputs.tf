output "sql_id" {
  value = azurerm_sql_database.example.id
}

output "data_lake_id" {
  value = azurerm_storage_account.example.id
}

output "key_vault_id" {
  value = azurerm_key_vault.example.id
}
