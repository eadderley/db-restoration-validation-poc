
resource "local_file" "source-mylogin-cnf" {

  content = templatefile("${path.module}/templates/mylogin.tftpl",
    {
      database_user     = var.database_user
      database_password = var.database_password
      database_host     = var.database_host_original
      database_name     = var.database_name
    }
  )
  filename = ".mylogin.cnf"
}

resource "null_resource" "original_db_query" {

  depends_on = [local_file.source-mylogin-cnf]

  provisioner "local-exec" {
    command = "mysql --defaults-file=.mylogin.cnf -t  < ${var.script} > original.db"
  }
}

resource "local_file" "restored-mylogin-cnf" {

  depends_on = [null_resource.original_db_query]
  content = templatefile("${path.module}/templates/mylogin.tftpl",
    {
      database_user     = var.database_user
      database_password = var.database_password
      database_host     = var.database_host_restored
      database_name     = var.database_name
    }
  )
  filename = ".mylogin.cnf"
}

resource "null_resource" "restored_db_query" {

  depends_on = [local_file.restored-mylogin-cnf]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
    mysql --defaults-file=.mylogin.cnf -t  < ${var.script} > restored.db
    rm .mylogin.cnf
    cat original.db
    cat restored.db
   EOT
  }
}