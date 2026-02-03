variable "backup_run_id" {
  description = "The id of the backup to use. Discoverable with `gcloud sql backups list -instance $instance_identifier`."
  type        = string
}

variable "database_name" {
  description = "The internal database test queries will be run against"
  type        = string
}

variable "instance_identifier" {
  description = "This is identifier for the source DB, the attributes of which will be used to stand up the restore."
  type        = string
}

variable "project_id" {
  description = "The full project id that the restore is being done in"
  type        = string
  validation {
    condition     = can(regex("^.*-[a-z0-9]{4}$", var.project_id))
    error_message = "Must be the full project id, i.e. platform-dev-rotw-67b6."
  }
}

variable "password_secret_id" {
  description = "The id of the GCP Secret Manager secret that will be used to query the DBs"
  type        = string
}

variable "database_user" {
  description = "The user that the queries will be made as"
  type        = string
}

variable "script_name" {
  description = "The name of the script to use in the scripts directory"
}