provider "azurerm" {
    features {}
}

data "azurerm_client_config" "current" {}

# Create Resource Group
resource "azurerm_resource_group" "example" {
    name      = local.rg_name
    location  = var.location


    tags = merge(
        local.common_tags, 
        {
            display_name = "Data Factory Resource Group"
        }
    )
}

# CREATE: Storage Account
resource "azurerm_storage_account" "example" {
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

# CREATE: Storage Account Container - CSV input
resource "azurerm_storage_container" "input" {
  name                  = "input"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

# CREATE: Storage Account Container - SQL bacpac
resource "azurerm_storage_container" "sql" {
  name                  = "bacpac"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

# UPLOAD: Initial CSV load for sample
resource "azurerm_storage_blob" "csv" {
  name                   = "emp.csv"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.input.name
  type                   = "Block"
  source                 = "../input/emp.csv"
}

# UPLOAD: Initial SQL bacpac file
resource "azurerm_storage_blob" "bacpac" {
  name                   = "dbo.bacpac"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.sql.name
  type                   = "Block"
  source                 = "../scripts/dbo.bacpac"
}

# CREATE: SQL server
resource "azurerm_sql_server" "example" {
    name                         = local.sql_server_name
    location                     = azurerm_resource_group.example.location
    resource_group_name          = azurerm_resource_group.example.name
    
    version                      = var.sql_version
    administrator_login          = var.sql_username
    administrator_login_password = var.sql_password

    tags = merge(
        local.common_tags, 
        {
            display_name = "SQL Server"
        }
    )
}

# CREATE: SQL server firewall rule - local machine
# GET: Current machine IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_sql_firewall_rule" "current_machine_ip" {
  name                = "fw-allow-${replace(data.http.myip.body,"\n","")}"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_sql_server.example.name
  start_ip_address    = replace(data.http.myip.body,"\n","")
  end_ip_address      = replace(data.http.myip.body,"\n","")
}

resource "azurerm_sql_firewall_rule" "sql_firewall_rull_ip_address" {
    count = length(var.sql_firewall_rull_ip_address) > 0 ? 1 : 0

  name                = "fw-allow-${var.sql_firewall_rull_ip_address}"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_sql_server.example.name
  start_ip_address    = var.sql_firewall_rull_ip_address
  end_ip_address      = var.sql_firewall_rull_ip_address
}

# CREATE: SQL server firewall rule - ADO server
# resource "azurerm_sql_virtual_network_rule" "sqlvnetrule" {
#   name                = "ado-sql-vnet-rule"
#   resource_group_name = azurerm_resource_group.example.name
#   server_name         = azurerm_sql_server.example.name
#   subnet_id           = data.azurerm_subnet.ado.id
# }

# CREATE: SQL DB
resource "azurerm_sql_database" "example" {
    name                = local.sql_db_name
    resource_group_name = azurerm_resource_group.example.name
    location            = azurerm_resource_group.example.location
    server_name         = azurerm_sql_server.example.name
    
    edition             = var.sql_edition

    zone_redundant      = var.sql_zone_redundant_enabled

    import {
        storage_uri = azurerm_storage_blob.bacpac.url
        storage_key = azurerm_storage_account.example.primary_access_key
        storage_key_type = "StorageAccessKey" # Valid values are StorageAccessKey or SharedAccessKey.
        administrator_login = var.sql_username
        administrator_login_password = var.sql_password
        authentication_type = "SQL" # Valid values are SQL or ADPassword.
    }

    tags = merge(
        local.common_tags, 
        {
            display_name = "SQL Database"
        }
    )

    depends_on = [
        azurerm_sql_firewall_rule.current_machine_ip,
        azurerm_sql_firewall_rule.sql_firewall_rull_ip_address

    ]
}

# CREATE: Key Vault
resource "azurerm_key_vault" "example" {
    name                        = local.kv_name
    location                    = azurerm_resource_group.example.location
    resource_group_name         = azurerm_resource_group.example.name
    enabled_for_disk_encryption = false
    tenant_id                   = data.azurerm_client_config.current.tenant_id
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

# CREATE: Azure SQL Secrets
resource "azurerm_key_vault_secret" "sql-username" {
  name         = "sql-username"
  value        = var.sql_username
  key_vault_id = azurerm_key_vault.example.id

    tags = merge(
        local.common_tags, 
        {
            display_name = "Key Vault secret SQL username"
        }
    )
}

resource "azurerm_key_vault_secret" "sql-password" {
  name         = "sql-password"
  value        = var.sql_password
  key_vault_id = azurerm_key_vault.example.id

    tags = merge(
        local.common_tags, 
        {
            display_name = "Key Vault secret SQL password"
        }
    )
}

# CREATE: Data Factory
resource "azurerm_data_factory" "example" {
    name                = local.df_name
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name

    identity {
        type = "SystemAssigned"
    }

    # dynamic "github_configuration" {
    #     for_each  = local.df_github_configuration

    #     content {
    #         account_name     = github_configuration.value["account_name"]
    #         branch_name      = github_configuration.value["branch_name"]
    #         git_url          = github_configuration.value["git_url"]
    #         repository_name  = github_configuration.value["repository_name"]
    #         root_folder      = github_configuration.value["root_folder"]
    #     }
    # }

    tags = merge(
        local.common_tags,
        {
            display_name = "Data Factory"
        }
    )
}

# UPDATE: Adding Access Policy for Azure Data Factory
resource "azurerm_key_vault_access_policy" "data_factory" {

    key_vault_id    = azurerm_key_vault.example.id
    
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_data_factory.example.identity.0.principal_id

    secret_permissions = [
        "get",
        "list"
    ]
}
