prefix = "agdf01"

environment_name = "dev"

location = "southcentralus"

sql_username = "sqladmin"

sql_password = "Pass@word!123"

sql_version = "12.0"

sql_edition = "Standard"

sql_zone_redundant_enabled = false

sql_firewall_rull_ip_address = "157.55.180.212"

sql_bacpac_file_path = "../input/db-dev.bacpac"

df_github_config = {
  account_name    = "aleguillen"
  branch_name     = "master"
  git_url         = "https://github.com"
  repository_name = "azure-data-factory"
  root_folder     = "/adls-to-sql/datafactory"
}