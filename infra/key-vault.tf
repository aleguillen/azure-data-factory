
# CREATE: Key Vault
resource "azurerm_key_vault" "example" {
  name                        = local.kv_name
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = false
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  # Access policy for current object id
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "get",
      "list",
      "set",
      "restore"
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = merge(
    local.common_tags,
    {
      display_name = "Key Vault"
    }
  )
}
