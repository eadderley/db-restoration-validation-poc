data "aws_db_instance" "original" {
  db_instance_identifier = var.instance_identifier
}


resource "aws_db_instance" "restored" {
  allocated_storage      = data.aws_db_instance.original.allocated_storage
  db_subnet_group_name   = data.aws_db_instance.original.db_subnet_group
  engine                 = data.aws_db_instance.original.engine
  engine_version         = data.aws_db_instance.original.engine_version
  identifier             = "${data.aws_db_instance.original.db_instance_identifier}-restore-test"
  instance_class         = data.aws_db_instance.original.db_instance_class
  option_group_name      = data.aws_db_instance.original.option_group_memberships[0]
  parameter_group_name   = data.aws_db_instance.original.db_parameter_groups[0]
  port                   = data.aws_db_instance.original.port
  skip_final_snapshot    = true
  storage_type           = data.aws_db_instance.original.storage_type
  username               = data.aws_db_instance.original.master_username
  vpc_security_group_ids = data.aws_db_instance.original.vpc_security_groups
  snapshot_identifier    = var.snapshot_identifier
}

data "aws_secretsmanager_secret_version" "db_pass" {
  secret_id = var.password_secret_version_id
}

locals {
  db_query_pass   = jsondecode(data.aws_secretsmanager_secret_version.db_pass.secret_string)["${var.password_secret_key_name}"]
  script          = "./scripts/${var.script_name}"
  database_name   = var.database_name == null ? data.aws_db_instance.original.db_name : var.database_name
  database_user   = var.database_user == null ? data.aws_db_instance.original.master_username : var.database_user
  run_mysql_tests = aws_db_instance.restored.engine == "mysql" ? 1 : 0
  run_psql_tests  = aws_db_instance.restored.engine == "postgres" ? 1 : 0
}

module "mysql_tests" {
  count                  = local.run_mysql_tests
  source                 = "../mysql_test"
  database_user          = local.database_user
  database_password      = local.db_query_pass
  database_name          = local.database_name
  database_host_original = data.aws_db_instance.original.address
  database_host_restored = aws_db_instance.restored.address
  script                 = local.script
}

module "psql_tests" {
  count                  = local.run_psql_tests
  source                 = "../psql_test"
  database_user          = local.database_user
  database_password      = local.db_query_pass
  database_port          = data.aws_db_instance.original.port
  database_name          = local.database_name
  database_host_original = data.aws_db_instance.original.address
  database_host_restored = aws_db_instance.restored.address
  script                 = local.script
}