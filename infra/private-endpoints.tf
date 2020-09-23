data "azurerm_resource_group" "pl" {
  count = length(var.private_link_resource_group_name) > 0 ? 1 : 0

  name = var.private_link_resource_group_name
}

data "azurerm_virtual_network" "pl" {
  count = length(var.private_link_vnet_name) > 0 ? 1 : 0

  name = var.private_link_vnet_name
  resource_group_name  = data.azurerm_resource_group.pl.0.name
}

data "azurerm_subnet" "pl" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                 = var.private_link_subnet_name
  virtual_network_name = data.azurerm_virtual_network.pl.0.name
  resource_group_name  = data.azurerm_resource_group.pl.0.name
}

############################################
############ DATA LAKE GEN2 ################
############################################

# CREATE: Private Endpoint to Data Lake Gen2
resource "azurerm_private_endpoint" "adls" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "pe-${azurerm_storage_account.example.name}"
  location            = data.azurerm_virtual_network.pl.0.location
  resource_group_name = data.azurerm_resource_group.pl.0.name
  subnet_id           = data.azurerm_subnet.pl.0.id

  private_service_connection {
    name                           = "pecon-${azurerm_storage_account.example.name}"
    private_connection_resource_id = azurerm_storage_account.example.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  tags = merge(
      local.common_tags, 
      {
          display_name = "Private Endpoint to Data Lake Gen2"
      }
  )
}

# CREATE: Private DNS zone to Data Lake
resource "azurerm_private_dns_zone" "adls" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "privatelink.dfs.core.windows.net"  
  resource_group_name = data.azurerm_resource_group.pl.0.name
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS zone to resolve storage private endpoint."
      }
  )
}

# CREATE: A record to Data Lake.
resource "azurerm_private_dns_a_record" "adls" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = azurerm_storage_account.example.name
  zone_name           = azurerm_private_dns_zone.adls.0.name
  resource_group_name = data.azurerm_resource_group.pl.0.name
  ttl                 = 3600
  records             = [azurerm_private_endpoint.adls.0.private_service_connection.0.private_ip_address]
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS record to Data Lake."
      }
  )
}

# CREATE: Link Private DNS zone with Virtual Network - Data Lake
resource "azurerm_private_dns_zone_virtual_network_link" "adls" {
  name                  = "dns-link-${azurerm_private_dns_zone.adls.0.name}"
  resource_group_name   = data.azurerm_resource_group.pl.0.name
  private_dns_zone_name = azurerm_private_dns_zone.adls.0.name
  virtual_network_id    = data.azurerm_virtual_network.pl.0.id
  registration_enabled  = false
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Data Lake Private DNS zone Link to VNET."
      }
  )
}


##########################################
############ BLOB STORAGE ################
##########################################

# CREATE: Private Endpoint to Blob Storage
resource "azurerm_private_endpoint" "blob" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "pe-${azurerm_storage_account.blob.name}"
  location            = data.azurerm_virtual_network.pl.0.location
  resource_group_name = data.azurerm_resource_group.pl.0.name
  subnet_id           = data.azurerm_subnet.pl.0.id

  private_service_connection {
    name                           = "pecon-${azurerm_storage_account.blob.name}"
    private_connection_resource_id = azurerm_storage_account.example.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = merge(
      local.common_tags, 
      {
          display_name = "Private Endpoint to Blob Storage"
      }
  )
}

# CREATE: Private DNS zone to Data Lake
resource "azurerm_private_dns_zone" "blob" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "privatelink.blob.core.windows.net"  
  resource_group_name = data.azurerm_resource_group.pl.0.name
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS zone to resolve blob storage private endpoint."
      }
  )
}

# CREATE: A record to Data Lake.
resource "azurerm_private_dns_a_record" "blob" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = azurerm_storage_account.example.name
  zone_name           = azurerm_private_dns_zone.blob.0.name
  resource_group_name = data.azurerm_resource_group.pl.0.name
  ttl                 = 3600
  records             = [azurerm_private_endpoint.blob.0.private_service_connection.0.private_ip_address]
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS record to Blob Storage."
      }
  )
}

# CREATE: Link Private DNS zone with Virtual Network - Data Lake
resource "azurerm_private_dns_zone_virtual_network_link" "adls" {
  name                  = "dns-link-${azurerm_private_dns_zone.blob.0.name}"
  resource_group_name   = data.azurerm_resource_group.pl.0.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.0.name
  virtual_network_id    = data.azurerm_virtual_network.pl.0.id
  registration_enabled  = false
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Blob Storage Private DNS zone Link to VNET."
      }
  )
}

############################################
################ KEY VAULT #################
############################################

# CREATE: Private Endpoint to Key Vault
resource "azurerm_private_endpoint" "kv" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "pe-${azurerm_key_vault.example.name}"
  location            = data.azurerm_virtual_network.pl.0.location
  resource_group_name = data.azurerm_resource_group.pl.0.name
  subnet_id           = data.azurerm_subnet.pl.0.id

  private_service_connection {
    name                           = "pecon-${azurerm_key_vault.example.name}"
    private_connection_resource_id = azurerm_key_vault.example.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  tags = merge(
      local.common_tags, 
      {
          display_name = "Private Endpoint to Data Lake Gen2"
      }
  )
}

# CREATE: Private DNS zone to Key Vault
resource "azurerm_private_dns_zone" "kv" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "privatelink.vaultcore.azure.net"  
  resource_group_name = data.azurerm_resource_group.pl.0.name
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS zone to Key Vault."
      }
  )
}

# CREATE: A record to Key Vault.
resource "azurerm_private_dns_a_record" "kv" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = azurerm_key_vault.example.name
  zone_name           = azurerm_private_dns_zone.kv.0.name
  resource_group_name = data.azurerm_resource_group.pl.0.name
  ttl                 = 3600
  records             = [azurerm_private_endpoint.kv.0.private_service_connection.0.private_ip_address]
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS record to Blob endpoint."
      }
  )
}

# CREATE: Link Private DNS zone with Virtual Network - Key Vault
resource "azurerm_private_dns_zone_virtual_network_link" "kv" {
  name                  = "dns-link-${azurerm_private_dns_zone.kv.0.name}"
  resource_group_name   = data.azurerm_resource_group.pl.0.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.0.name
  virtual_network_id    = data.azurerm_virtual_network.pl.0.id
  registration_enabled  = false
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Key Vault Private DNS zone Link to VNET."
      }
  )
}

############################################
################ SQL Server ################
############################################

# CREATE: Private Endpoint to SQL
resource "azurerm_private_endpoint" "sql" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "pe-${azurerm_sql_server.example.name}"
  location            = data.azurerm_virtual_network.pl.0.location
  resource_group_name = data.azurerm_resource_group.pl.0.name
  subnet_id           = data.azurerm_subnet.pl.0.id

  private_service_connection {
    name                           = "pecon-${azurerm_sql_server.example.name}"
    private_connection_resource_id = azurerm_sql_server.example.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  tags = merge(
      local.common_tags, 
      {
          display_name = "Private Endpoint to SQL Server"
      }
  )
}

# CREATE: Private DNS zone to SQL
resource "azurerm_private_dns_zone" "sql" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "privatelink.database.windows.net"  
  resource_group_name = data.azurerm_resource_group.pl.0.name
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS zone to SQL."
      }
  )
}

# CREATE: A record to SQL.
resource "azurerm_private_dns_a_record" "sql" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = azurerm_sql_server.example.name
  zone_name           = azurerm_private_dns_zone.sql.0.name
  resource_group_name = data.azurerm_resource_group.pl.0.name
  ttl                 = 3600
  records             = [azurerm_private_endpoint.sql.0.private_service_connection.0.private_ip_address]
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS record to SQL endpoint."
      }
  )
}

# CREATE: Link Private DNS zone with Virtual Network - SQL
resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "dns-link-${azurerm_private_dns_zone.sql.0.name}"
  resource_group_name   = data.azurerm_resource_group.pl.0.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.0.name
  virtual_network_id    = data.azurerm_virtual_network.pl.0.id
  registration_enabled  = false
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "SQL Private DNS zone Link to VNET."
      }
  )
}


##############################################
################ Data Factory ################
##############################################

# CREATE: Private Endpoint to Data Factory
resource "azurerm_private_endpoint" "adf" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "pe-${azurerm_data_factory.example.name}"
  location            = data.azurerm_virtual_network.pl.0.location
  resource_group_name = data.azurerm_resource_group.pl.0.name
  subnet_id           = data.azurerm_subnet.pl.0.id

  private_service_connection {
    name                           = "pecon-${azurerm_data_factory.example.name}"
    private_connection_resource_id = azurerm_data_factory.example.id
    is_manual_connection           = false
    subresource_names              = ["dataFactory"]
  }

  tags = merge(
      local.common_tags, 
      {
          display_name = "Private Endpoint to Data Factory"
      }
  )
}

# CREATE: Private Endpoint to Data Factory
# resource "azurerm_private_endpoint" "adfportal" {
#   count = length(var.private_link_subnet_name) > 0 ? 1 : 0

#   name                = "pe-${azurerm_data_factory.example.name}-portal"
#   location            = data.azurerm_virtual_network.pl.0.location
#   resource_group_name = data.azurerm_resource_group.pl.0.name
#   subnet_id           = data.azurerm_subnet.pl.0.id

#   private_service_connection {
#     name                           = "pecon-${azurerm_data_factory.example.name}-portal"
#     private_connection_resource_id = azurerm_data_factory.example.id
#     is_manual_connection           = false
#     subresource_names              = ["portal"]
#   }

#   tags = merge(
#       local.common_tags, 
#       {
#           display_name = "Private Endpoint to Data Factory"
#       }
#   )
# }


# CREATE: Private DNS zone to Data Factory
resource "azurerm_private_dns_zone" "adf" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "privatelink.datafactory.azure.net"  
  resource_group_name = data.azurerm_resource_group.pl.0.name
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS zone to Data Factory."
      }
  )
}

# CREATE: A record to Data Factory.
resource "azurerm_private_dns_a_record" "adf" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "${azurerm_data_factory.example.name}.${azurerm_data_factory.example.location}"
  zone_name           = azurerm_private_dns_zone.adf.0.name
  resource_group_name = data.azurerm_resource_group.pl.0.name
  ttl                 = 3600
  records             = [azurerm_private_endpoint.adf.0.private_service_connection.0.private_ip_address]
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS record to Data Factory endpoint."
      }
  )
}

# CREATE: Link Private DNS zone with Virtual Network - Data Factory
resource "azurerm_private_dns_zone_virtual_network_link" "adf" {
  name                  = "dns-link-${azurerm_private_dns_zone.adf.0.name}"
  resource_group_name   = data.azurerm_resource_group.pl.0.name
  private_dns_zone_name = azurerm_private_dns_zone.adf.0.name
  virtual_network_id    = data.azurerm_virtual_network.pl.0.id
  registration_enabled  = false
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Data Factory Private DNS zone Link to VNET."
      }
  )
}


#####################################################
################ Data Factory Portal ################
#####################################################


CREATE: Private Endpoint to Data Factory
resource "azurerm_private_endpoint" "adfportal" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "pe-${azurerm_data_factory.example.name}-portal"
  location            = data.azurerm_virtual_network.pl.0.location
  resource_group_name = data.azurerm_resource_group.pl.0.name
  subnet_id           = data.azurerm_subnet.pl.0.id

  private_service_connection {
    name                           = "pecon-${azurerm_data_factory.example.name}-portal"
    private_connection_resource_id = azurerm_data_factory.example.id
    is_manual_connection           = false
    subresource_names              = ["portal"]
  }

  tags = merge(
      local.common_tags, 
      {
          display_name = "Private Endpoint to Data Factory Portal"
      }
  )
}


# CREATE: Private DNS zone to Data Factory
resource "azurerm_private_dns_zone" "adfportal" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "privatelink.azure.com"  
  resource_group_name = data.azurerm_resource_group.pl.0.name
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS zone to Data Factory."
      }
  )
}

# CREATE: A record to Data Factory.
resource "azurerm_private_dns_a_record" "adfportal" {
  count = length(var.private_link_subnet_name) > 0 ? 1 : 0

  name                = "adf"
  zone_name           = azurerm_private_dns_zone.adfportal.0.name
  resource_group_name = data.azurerm_resource_group.pl.0.name
  ttl                 = 3600
  records             = [azurerm_private_endpoint.adfportal.0.private_service_connection.0.private_ip_address]
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Private DNS record to Data Factory Portal endpoint."
      }
  )
}

# CREATE: Link Private DNS zone with Virtual Network - Data Factory Portal
resource "azurerm_private_dns_zone_virtual_network_link" "adfportal" {
  name                  = "dns-link-${azurerm_private_dns_zone.adfportal.0.name}"
  resource_group_name   = data.azurerm_resource_group.pl.0.name
  private_dns_zone_name = azurerm_private_dns_zone.adfportal.0.name
  virtual_network_id    = data.azurerm_virtual_network.pl.0.id
  registration_enabled  = false
  
  tags = merge(
      local.common_tags, 
      {
          display_name = "Data Factory Portal Private DNS zone Link to VNET."
      }
  )
}