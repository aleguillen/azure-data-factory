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

  # validation {
  #   condition = can(regex("(?=^[a-zA-Z]{4}$)(?=(dev|acc|prd|nprd))", var.environment_name))
  #   error_message = "The environment_name value must be either: dev, acc, prd or nprd."
  # }
}

variable "location" {
  type        = string
  description = "The Azure region where your resources will be created."
}

variable "common_tags" {
  type        = map(string)
  description = "Common resources tags. Key-value pair"
  default     = {}
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

variable "sql_firewall_rull_ip_addresses" {
  type        = list(string)
  description = "SQL Firewall rule to allow access to execute BACPAC file."
  default     = []
}

variable "sql_bacpac_file_path" {
  type        = string
  description = "SQL .bacpac file location to upload and use to import into SQL DB."
  default     = ""
}

variable "df_github_config" {
  type = object({
    account_name    = string
    branch_name     = string
    git_url         = string
    repository_name = string
    root_folder     = string
  })
  description = "Data Factory Github integration."
  default     = null
}

variable "private_link_resource_group_name" {
  type        = string
  description = "Resource Group Name where the Private Link Subnet is located."
}

variable "private_link_vnet_name" {
  type        = string
  description = "Virtual Network Name where the Private Link Subnet is located."
}

variable "private_link_subnet_name" {
  type        = string
  description = "Subnet Name for the Private Link Subnet."
}