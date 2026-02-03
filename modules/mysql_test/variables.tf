variable "database_host_original" {
  description = "The address of the original DB"
  type        = string
}

variable "database_host_restored" {
  description = "The address of the restored DB"
  type        = string
}

variable "database_name" {
  description = "The internal database test queries will be run against"
  type        = string
}

variable "database_user" {
  description = "The user that the queries will be made as"
  type        = string
}

variable "database_password" {
  description = "The password for the target DB"
  type        = string
}

variable "script" {
  description = "The script that will be run against the original and restored DBs"
  type        = string
}
