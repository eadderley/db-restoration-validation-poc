variable "database_name" {
  description = "The internal database test queries will be run against"
  default     = null
  type        = string
}

variable "database_user" {
  description = "The user that the queries will be made as"
  default     = null
  type        = string
}

variable "instance_identifier" {
  description = "This is identifier for the source DB, the attributes of which will be used to stand up the restore."
  type        = string
}

variable "snapshot_identifier" {
  description = "This is identifier for the snapshot that will be used for the restore."
  type        = string
}

variable "password_secret_version_id" {
  description = "The version id of the AWS Secret Manager secret that will be used to query the DBs"
  type        = string
}

variable "password_secret_key_name" {
  description = "The id of the key in the secret version that contains the db password"
  type        = string
}

variable "script_name" {
  description = "The name of the script to use in the scripts directory"
}