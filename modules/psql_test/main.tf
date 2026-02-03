
resource "local_file" "source-pgpass" {

  content = templatefile("${path.module}/templates/pgpass.tftpl",
    {
      database_user     = var.database_user
      database_password = var.database_password
      database_port     = var.database_port
      database_host     = var.database_host_original
      database_name     = var.database_name
    }
  )
  filename        = ".pgpass"
  file_permission = 0600
}

resource "null_resource" "original_db_query" {

  depends_on = [local_file.source-pgpass]

  provisioner "local-exec" {
    command = <<-EOT
    export PGPASSFILE="$(pwd)/.pgpass"
    psql -U ${var.database_user} -h ${var.database_host_original} ${var.database_name} -f ${var.script} > original.db
    EOT
  }
}

resource "local_file" "restored-pgpass" {

  depends_on = [null_resource.original_db_query]
  content = templatefile("${path.module}/templates/pgpass.tftpl",
    {
      database_user     = var.database_user
      database_password = var.database_password
      database_port     = var.database_port
      database_host     = var.database_host_restored
      database_name     = var.database_name
    }
  )
  filename        = ".pgpass"
  file_permission = 0600
}

resource "null_resource" "restored_db_query" {

  depends_on = [local_file.restored-pgpass]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
    export PGPASSFILE="$(pwd)/.pgpass"
    psql -U ${var.database_user} -h ${var.database_host_restored} ${var.database_name} -f ${var.script} > restored.db

    cat original.db
    cat restored.db
   EOT
  }
}

resource "null_resource" "cat_files" {

  depends_on = [null_resource.restored_db_query]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
    echo ""
    echo "======ORIGINAL DATABASE INFORMATION======="
    echo ""
    cat original.db
    echo ""
    echo "======RESTORED DATABASE INFORMATION======="
    echo ""
    cat restored.db
   EOT
  }
}