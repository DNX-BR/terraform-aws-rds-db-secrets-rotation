resource "aws_ssm_parameter" "rds_db_password" {
  count       = var.secret_method == "ssm" ? 1 : 0
  name        = "/rds/${var.environment_name}-${var.name}/PASSWORD"
  description = "RDS Password"
  type        = "SecureString"
  value       = random_string.rds_db_password.result

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "rds_db_user" {
  count       = var.secret_method == "ssm" ? 1 : 0
  name        = "/rds/${var.environment_name}-${var.name}/USER"
  description = "RDS User"
  type        = "SecureString"
  value       = var.db_type == "rds" ? aws_db_instance.rds_db[0].username : aws_rds_cluster.aurora_cluster[0].master_username
}

resource "aws_ssm_parameter" "rds_endpoint" {
  count       = var.secret_method == "ssm" ? 1 : 0
  name        = "/rds/${var.environment_name}-${var.name}/ENDPOINT"
  description = "RDS Endpoint"
  type        = "String"
  value       = var.db_type == "rds" ? aws_db_instance.rds_db[0].endpoint : aws_rds_cluster.aurora_cluster[0].endpoint
}


resource "aws_ssm_parameter" "rds_reader_endpoint" {
  count       = var.db_type == "aurora" && var.secret_method == "ssm" ? 1 : 0
  name        = "/rds/${var.environment_name}-${var.name}/READER_ENDPOINT"
  description = "RDS Reader Endpoint"
  type        = "String"
  value       = aws_rds_cluster.aurora_cluster[0].reader_endpoint
}

resource "aws_ssm_parameter" "rds_db_address" {
  count       = var.secret_method == "ssm" ? 1 : 0
  name        = "/rds/${var.environment_name}-${var.name}/HOST"
  description = "RDS Hostname"
  type        = "String"
  value       = var.db_type == "rds" ? aws_db_instance.rds_db[0].address : aws_rds_cluster.aurora_cluster[0].endpoint
}

resource "aws_ssm_parameter" "rds_db_name" {
  count       = var.database_name == "" ? 0 : 1
  name        = "/rds/${var.environment_name}-${var.name}/NAME"
  description = "RDS DB Name"
  type        = "String"
  value       = var.db_type == "rds" ? aws_db_instance.rds_db[0].name : aws_rds_cluster.aurora_cluster[0].database_name
}
