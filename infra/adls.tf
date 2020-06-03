
# CREATE: Data Lake Gen2
resource "azurerm_storage_account" "example" {
  name                     = local.dl_storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  is_hns_enabled = true

  tags = merge(
    local.common_tags,
    {
      display_name = "Data Lake"
    }
  )
}

# CREATE: Data Lake Gen2 File System
resource "azurerm_storage_data_lake_gen2_filesystem" "example" {
  name               = "input"
  storage_account_id = azurerm_storage_account.example.id
}

# UPLOAD: Initial CSV load for sample
resource "azurerm_storage_blob" "csv" {
  name                   = "emp.csv"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_data_lake_gen2_filesystem.example.name
  type                   = "Block"
  source                 = "../input/emp.csv"
}

