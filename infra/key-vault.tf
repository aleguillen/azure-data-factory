
# CREATE: Key Vault
resource "azurerm_key_vault" "example" {
  name                        = local.kv_name
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = false
  soft_delete_enabled         = true
  purge_protection_enabled    = true

  sku_name = "standard"

  # Access policy for current object id
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "create", "decrypt", "delete", "encrypt", "get", "import", "list", "purge", "recover", "restore", "sign", "unwrapKey", "update", "verify", "wrapKey"
    ]

    secret_permissions = [
      "get", "list", "set",   "restore"
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = merge(
    local.common_tags,
    {
      display_name = "Key Vault"
    }
  )
}

# CREATE: CMK key to Encrypt data
resource "azurerm_key_vault_key" "generated" {
  name         = "cmk-encrypt-key"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}