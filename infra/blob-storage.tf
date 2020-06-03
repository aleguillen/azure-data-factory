# CREATE: Blob Storage
resource "azurerm_storage_account" "blob" {
  count = length(var.sql_bacpac_file_path) > 0 ? 1 : 0

  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = merge(
    local.common_tags,
    {
      display_name = "Storage Account"
    }
  )
}

# CREATE: Storage Account Container
resource "azurerm_storage_container" "blob" {
  count = length(var.sql_bacpac_file_path) > 0 ? 1 : 0

  name                  = "bacpac"
  storage_account_name  = azurerm_storage_account.blob.0.name
  container_access_type = "private"
}

# UPLOAD: Upload BACPAC file to use as import in SQL DB
resource "azurerm_storage_blob" "bacpac" {
  count = length(var.sql_bacpac_file_path) > 0 ? 1 : 0

  name                   = basename(var.sql_bacpac_file_path)
  storage_account_name   = azurerm_storage_account.blob.0.name
  storage_container_name = azurerm_storage_container.blob.0.name
  type                   = "Block"
  source                 = var.sql_bacpac_file_path
}

data "azurerm_storage_account" "blob" {
  count = length(var.sql_bacpac_file_path) > 0 ? 1 : 0
  
  name                     = azurerm_storage_account.blob.0.name
  resource_group_name      = azurerm_resource_group.example.name
}
