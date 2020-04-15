locals {

  rg_name   = "${var.prefix}-${var.location}-${var.environment_name}-rg"

  df_name   = "${var.prefix}-${var.location}-${var.environment_name}-df"

  kv_name   = "${var.prefix}${var.location}${var.environment_name}kv"

  sql_server_name   = "${var.prefix}-${var.location}-${var.environment_name}-sqlsrv"

  sql_db_name   = "${var.prefix}-${var.location}-${var.environment_name}-sqldb"

  storage_account_name   = "${var.prefix}${var.location}${var.environment_name}sa"
  
  # df_github_configuration = var.environment_name == "dev" && var.df_github_config == null ? list(var.df_github_config) : null

  common_tags = {
    environment = var.environment_name
    source      = "terraform"
    owner       = "Alejandra Guillen"
  }
}
