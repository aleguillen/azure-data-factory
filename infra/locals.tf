locals {
  # General
  naming_conv = "${var.prefix}-${var.environment_name}"

  naming_conv_2 = "${var.prefix}${var.environment_name}"
  
  unique_rg_string = md5(azurerm_resource_group.example.id)

  rg_name = "rg-${local.naming_conv}"

  common_tags = merge(
    var.common_tags,
    {
      environment   = var.environment_name
      # last_modified = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
    }
  )

  # Data Factory
  df_name = "df-${local.naming_conv}"

  df_github_configuration = var.environment_name == "dev" ? (var.df_github_config == null ? [] : list(var.df_github_config)) : []

  # Key Vault
  kv_name = "kv-${local.naming_conv}"

  # SQL Details
  sql_server_name = "sql-${local.naming_conv}"

  sql_db_name = "sqldb-${local.naming_conv}"

  storage_account_name = "sa${local.naming_conv_2}${substr(local.unique_rg_string, 0, 10)}"

  # Data Lake
  dl_storage_account_name = "dls${local.naming_conv_2}${substr(local.unique_rg_string, 0, 10)}"

}
