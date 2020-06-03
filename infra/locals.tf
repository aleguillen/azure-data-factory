locals {
  # General
  rg_name = "rg-${var.prefix}-${var.environment_name}"

  common_tags = merge(
    var.common_tags,
    {
      environment   = var.environment_name
      # last_modified = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
    }
  )

  # Data Factory
  df_name = "df-${var.prefix}-${var.environment_name}"

  df_github_configuration = var.environment_name == "dev" ? (var.df_github_config == null ? [] : list(var.df_github_config)) : []

  # Key Vault
  kv_name = "kv-${var.prefix}-${var.environment_name}"

  # SQL Details
  sql_server_name = "sql-${var.prefix}-${var.environment_name}"

  sql_db_name = "sqldb-${var.prefix}-${var.environment_name}"

  storage_account_name = "sa${var.prefix}${var.environment_name}${substr(md5(azurerm_resource_group.example.id), 0, 10)}"

  # Data Lake
  dl_storage_account_name = "dls${var.prefix}${var.environment_name}${substr(md5(azurerm_resource_group.example.id), 0, 10)}"

}
