resource "aws_iam_role" "lambda_rotate_secrets" {
  count              = var.secrets_manager && var.secret_rotation ? 1 : 0
  name               = "lambda-rotate-rds-secret-${var.environment_name}-${var.name}-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy[0].json

  inline_policy {
    name   = "LambdaBasic"
    policy = data.aws_iam_policy_document.basic[0].json
  }

  inline_policy {
    name   = "Secrets"
    policy = data.aws_iam_policy_document.secrets[0].json
  }

  inline_policy {
    name   = "KMS"
    policy = data.aws_iam_policy_document.kms[0].json
  }
}


resource "aws_lambda_function" "lambda_rotate_secrets" {
  count = var.secrets_manager && var.secret_rotation ? 1 : 0

  function_name    = "lambda-rotate-rds-secret-${var.environment_name}-${var.name}"
  filename         = "${path.module}/lambda_files/lambda-rotate-secrets.zip"
  role             = aws_iam_role.lambda_rotate_secrets[0].arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda_files/lambda-rotate-secrets.zip")
  runtime          = "python3.9"
  timeout          = 30

  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = [aws_security_group.rds_db.id]
  }

  environment {
    variables = {
      EXCLUDE_CHARACTERS       =  var.secret_exclude_characters#"/@\"'\\"
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_lambda_permission" "allow_secrets_manager" {
  count = var.secrets_manager && var.secret_rotation ? 1 : 0

  statement_id  = "AllowExecutionFromSecretManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_rotate_secrets[0].function_name
  principal     = "secretsmanager.amazonaws.com"
}
