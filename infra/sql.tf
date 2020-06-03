
# CREATE: SQL server
resource "azurerm_sql_server" "example" {
  name                = local.sql_server_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

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
  name                = "fw-allow-${replace(data.http.myip.body, "\n", "")}"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_sql_server.example.name
  start_ip_address    = replace(data.http.myip.body, "\n", "")
  end_ip_address      = replace(data.http.myip.body, "\n", "")
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

  edition = var.sql_edition

  zone_redundant = var.sql_zone_redundant_enabled

  dynamic "import" {
    for_each = length(var.sql_bacpac_file_path) > 0 ? [var.sql_bacpac_file_path] : []
    
    content {
      storage_uri                  = azurerm_storage_blob.bacpac.0.url
      storage_key                  = data.azurerm_storage_account.blob.0.secondary_access_key
      storage_key_type             = "StorageAccessKey"
      administrator_login          = var.sql_username
      administrator_login_password = var.sql_password
      authentication_type          = "SQL"
      operation_mode               = "Import"
    }
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