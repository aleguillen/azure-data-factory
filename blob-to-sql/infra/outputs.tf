output "sql_id" {
  value = azurerm_data_factory.example.id
}

output "storage_account_id" {
  value = azurerm_sql_database.example.id
}

output "storage" {
  value = azurerm_storage_account.example
}