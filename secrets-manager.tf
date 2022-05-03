resource "aws_secretsmanager_secret" "rds" {
  count                   = var.secret_method == "secretsmanager" ? 1 : 0
  name                    = var.identifier == "" ? "/rds/${var.environment_name}-${var.name}" : "/rds/${var.identifier}"
  recovery_window_in_days = 0
}

locals {
  secrets = {
    host            = var.db_type == "rds" ? aws_db_instance.rds_db[0].address : aws_rds_cluster.aurora_cluster[0].endpoint
    endpoint        = var.db_type == "rds" ? aws_db_instance.rds_db[0].endpoint : aws_rds_cluster.aurora_cluster[0].endpoint
    username        = var.db_type == "rds" ? aws_db_instance.rds_db[0].username : aws_rds_cluster.aurora_cluster[0].master_username
    password        = random_string.rds_db_password.result
    port            = var.db_type == "rds" ? aws_db_instance.rds_db[0].port : aws_rds_cluster.aurora_cluster[0].port
    identifier      = var.db_type == "rds" ? aws_db_instance.rds_db[0].name : aws_rds_cluster.aurora_cluster[0].cluster_identifier
    engine          = var.db_type == "rds" ? aws_db_instance.rds_db[0].engine : aws_rds_cluster.aurora_cluster[0].engine
    reader_endpoint = var.db_type == "aurora" ? aws_rds_cluster.aurora_cluster[0].reader_endpoint : "null"
  }
  rds_secret = local.secrets
}

resource "aws_secretsmanager_secret_version" "rds" {
  count         = var.secret_method == "secretsmanager" ? 1 : 0
  secret_id     = aws_secretsmanager_secret.rds[0].id
  secret_string = jsonencode(local.rds_secret)
}

resource "aws_secretsmanager_secret_rotation" "secret" {
  count = var.secret_method == "secretsmanager" && var.secret_rotation ? 1 : 0

  secret_id           = aws_secretsmanager_secret.rds[0].id
  rotation_lambda_arn = aws_lambda_function.lambda_rotate_secrets[0].arn

  rotation_rules {
    automatically_after_days = var.secret_rotate_days
  }
}
