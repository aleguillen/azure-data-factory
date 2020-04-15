variable "prefix" {
  type        = string
  description = "The prefix for all your resources. Ex.: <prefix>-rg, <prefix>-vnet"

#   validation {
#         condition = can(regex("^[a-z]{1}[a-z0-9]{1,4}$", var.prefix))
#         error_message = "The prefix value must be from 2 to 3 characters long. Must start with a letter. Only alphanumeric numbers are allowed."
#   }
}

variable "environment_name" {
  type        = string
  description = "Environment Name."
  default     = "dev"
  
#   validation {
#         condition = can(regex("(?=^[a-z]{3}$)(?=(dev|acc|prd))", var.environment_name))
#         error_message = "The environment_name value must be either: dev, acc or prd."
#   }
}

variable "location" {
  type        = string
  description = "The Azure region where your resources will be created."
  default     = "southcentralus"
}

variable "sql_username" {
  type        = string
  description = "The username for the SQL Server."
}

variable "sql_password" {
  type        = string
  description = "The password for the SQL Server."
}

variable "sql_version" {
  type        = string
  description = "SQL Server version."
  default     = "12.0"
}

variable "sql_edition" {
  type        = string
  description = "SQL Server version."
  default     = "Standard"
}

variable "sql_zone_redundant_enabled" {
  type        = bool
  description = "Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones."
  default     = false
}

variable "sql_firewall_rull_ip_address" {
    type        = string
    description = "SQL Firewall rule to allow access to execute BACPAC file."
    default     = ""
}

variable "df_github_config" {
  type = object({
    account_name     = string
    branch_name      = string
    git_url          = string
    repository_name  = string
    root_folder      = string
  })
  description = "Data Factory Github integration."
  default     =  null
}
