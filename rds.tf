resource "random_string" "rds_db_password" {
  length  = 34
  special = false
}

resource "aws_db_instance" "rds_db" {
  count                           = var.db_type == "rds" ? 1 : 0
  publicly_accessible             = var.publicly_accessible
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  storage_type                    = "gp2"
  license_model                   = var.license_model
  engine                          = var.engine
  engine_version                  = var.engine_version
  instance_class                  = var.instance_class
  name                            = var.database_name
  backup_retention_period         = var.retention
  identifier                      = var.identifier == "" ? "${var.environment_name}-${var.name}" : var.identifier
  username                        = var.user
  password                        = random_string.rds_db_password.result
  db_subnet_group_name            = try(aws_db_subnet_group.rds_subnet_group[0].id, var.db_subnet_group_id)
  vpc_security_group_ids          = [aws_security_group.rds_db.id]
  apply_immediately               = var.apply_immediately
  skip_final_snapshot             = var.skip_final_snapshot
  snapshot_identifier             = var.snapshot_identifier != "" ? var.snapshot_identifier : null
  kms_key_id                      = var.kms_key_arn
  multi_az                        = var.multi_az
  storage_encrypted               = var.storage_encrypted
  parameter_group_name            = var.create_db_parameter_group == true ? aws_db_parameter_group.rds_custom_db_pg[count.index].name : ""
  option_group_name               = var.create_db_option_group == true ? aws_db_option_group.rds_custom_db_og[count.index].name : ""
  deletion_protection             = var.deletion_protection
  performance_insights_enabled    = var.performance_insights_enabled
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[count.index].arn : ""
  maintenance_window              = var.maintenance_window
  backup_window                   = var.backup_window
  tags                            = var.tags
}


resource "aws_db_parameter_group" "rds_custom_db_pg" {
  count = var.create_db_parameter_group ? 1 : 0

  name        = var.parameter_group_name
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


resource "aws_db_option_group" "rds_custom_db_og" {
  count = var.create_db_option_group ? 1 : 0

  name                     = var.option_group_name
  option_group_description = var.option_group_description
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version
  option {
    option_name = var.option_name
    dynamic "option_settings" {
      for_each = var.options
      content {
        name  = option_settings.value.name
        value = option_settings.value.value
      }
    }
  }

  tags = {
    "Name" = var.option_group_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name                = "rds-${var.name}-enhanced-monitoring"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
}
