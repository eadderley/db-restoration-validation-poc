
data "google_sql_database_instance" "original" {
  project = var.project_id
  name    = var.instance_identifier
}

resource "google_sql_database_instance" "restored" {
  database_version    = data.google_sql_database_instance.original.database_version
  deletion_protection = false
  instance_type       = "CLOUD_SQL_INSTANCE"
  name                = "${data.google_sql_database_instance.original.id}-restore-test"
  project             = data.google_sql_database_instance.original.project
  region              = data.google_sql_database_instance.original.region
  restore_backup_context {
    backup_run_id = var.backup_run_id
    instance_id   = var.instance_identifier
  }
  settings {
    activation_policy            = data.google_sql_database_instance.original.settings[0].activation_policy
    availability_type            = data.google_sql_database_instance.original.settings[0].availability_type
    deletion_protection_enabled  = false
    disk_autoresize              = false
    disk_size                    = data.google_sql_database_instance.original.settings[0].disk_size
    disk_type                    = data.google_sql_database_instance.original.settings[0].disk_type
    edition                      = data.google_sql_database_instance.original.settings[0].edition
    enable_dataplex_integration  = false
    enable_google_ml_integration = false
    pricing_plan                 = data.google_sql_database_instance.original.settings[0].pricing_plan
    retain_backups_on_delete     = false
    tier                         = data.google_sql_database_instance.original.settings[0].tier
    backup_configuration {
      binary_log_enabled             = false
      enabled                        = false
      point_in_time_recovery_enabled = false
    }
    ip_configuration {
      ssl_mode = data.google_sql_database_instance.original.settings[0].ip_configuration[0].ssl_mode
      /*
      authorized_networks {
        name            = tolist(tolist(tolist(data.google_sql_database_instance.original.settings)[0].ip_configuration)[0].authorized_networks)[0].name
        value           = tolist(tolist(tolist(data.google_sql_database_instance.original.settings)[0].ip_configuration)[0].authorized_networks)[0].value
      }
      */
      private_network = data.google_sql_database_instance.original.settings[0].ip_configuration[0].private_network
    }
  }
}

locals {
  script = "./scripts/${var.script_name}"
}
data "google_secret_manager_secret" "db_pass" {
  project   = var.project_id
  secret_id = var.password_secret_id
}

data "google_secret_manager_secret_version" "basic" {
  project = var.project_id
  secret  = var.password_secret_id
}

module "psql_tests" {
  source                 = "../psql_test"
  database_user          = var.database_user
  database_password      = data.google_secret_manager_secret_version.basic.secret_data
  database_port          = "5432"
  database_name          = var.database_name
  database_host_original = data.google_sql_database_instance.original.private_ip_address
  database_host_restored = google_sql_database_instance.restored.private_ip_address
  script                 = local.script
}
