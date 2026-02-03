/*
module "aws_db_restore_test" {
  source                     = "./modules/aws_restore"
  instance_identifier        = "message-reporting-dev-us"
  snapshot_identifier        = "rds:message-reporting-dev-us-2025-09-06-05-11"
  password_secret_version_id = "arn:aws:secretsmanager:us-east-1:455077397705:secret:rds_restore_test-jwxlkB"
  password_secret_key_name   = "db_admin"
  script_name                = "message-reporting-dev.sql"
}
*/

module "gcp_db_restore_test" {
  source              = "./modules/gcp_restore"
  project_id          = "portal-prd-rotw-ea62"
  instance_identifier = "billing-db-prd-rotw"
  backup_run_id       = "1761318000000"
  password_secret_id  = "prd-billing-restore-test"
  database_user       = "billing_role"
  database_name       = "billing"
  script_name         = "billing.sql"
}
