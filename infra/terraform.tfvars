prefix = "<replace-me>"

environment_name = "dev"

location = "<replace-me>"

sql_username = "<replace-me>"

sql_password = "<replace-me>"

sql_version = "12.0"

sql_edition = "Standard"

sql_zone_redundant_enabled = false

# Get using CLI
# Current signed-in user: az ad signed-in-user show --query "[userPrincipalName, objectId]"
# sql_ad_administrator = {
#     "user@domain.com": "11111111-2222-3333-4444-555555555555"
# }
sql_ad_administrator = null

sql_firewall_rull_ip_address = ["0.0.0.0"] # 0.0.0.0 -> Public Internet Access Allowed 

sql_bacpac_file_path = "../scripts/db-dev.bacpac"

df_github_config = null

# Bastion Network details for Private Link settings
private_link_resource_group_name = "<replace-me>"
private_link_vnet_name = "<replace-me>"
private_link_subnet_name = "<replace-me>"
