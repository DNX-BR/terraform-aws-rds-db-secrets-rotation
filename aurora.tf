resource "aws_rds_cluster" "aurora_cluster" {
  count                               = var.db_type == "aurora" ? 1 : 0
  cluster_identifier                  = var.identifier == "" ? "${var.environment_name}-${var.name}" : var.identifier
  engine                              = var.engine
  engine_version                      = var.engine_version
  database_name                       = var.database_name
  master_username                     = var.user
  master_password                     = random_string.rds_db_password.result
  backup_retention_period             = var.retention
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  snapshot_identifier                 = var.snapshot_identifier != "" ? var.snapshot_identifier : null
  db_subnet_group_name                = try(aws_db_subnet_group.rds_subnet_group[0].id, var.db_subnet_group_id)
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  vpc_security_group_ids              = [aws_security_group.rds_db.id]
  db_cluster_parameter_group_name     = var.create_cluster_parameter_group == true ? aws_rds_cluster_parameter_group.custom_cluster_pg[count.index].name : ""
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                   = var.db_type == "aurora" ? var.count_aurora_instances : 0
  identifier              = var.identifier == "" ? "${var.environment_name}-${var.name}-${count.index}" : "${var.identifier}-${count.index}"
  cluster_identifier      = aws_rds_cluster.aurora_cluster[0].id
  instance_class          = var.instance_class
  engine                  = aws_rds_cluster.aurora_cluster[0].engine
  engine_version          = aws_rds_cluster.aurora_cluster[0].engine_version
  db_parameter_group_name = var.create_db_parameter_group == true ? aws_db_parameter_group.aurora_custom_db_pg[count.index].name : ""

}

resource "aws_rds_cluster_parameter_group" "custom_cluster_pg" {
  count = var.db_type == "aurora" && var.create_cluster_parameter_group ? 1 : 0

  name = var.parameter_group_name
  #name_prefix = local.name_prefix
  description = var.parameter_group_description
  family      = var.family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

}

resource "aws_db_parameter_group" "aurora_custom_db_pg" {
  count = var.db_type == "aurora" && var.create_db_parameter_group ? 1 : 0

  #name = var.parameter_group_name
  name_prefix = var.parameter_group_name
  description = var.parameter_group_description
  family      = var.family

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = {
    "Name" = var.parameter_group_name
  }

  lifecycle {
    create_before_destroy = true
  }
}
