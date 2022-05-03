resource "aws_iam_role" "lambda_rotate_secrets" {
  count              = var.secret_method == "secretsmanager" && var.secret_rotation ? 1 : 0
  name               = "lambda-rotate-secrets-${var.environment_name}-${data.aws_region.current.name}"
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

data "aws_iam_policy_document" "instance_assume_role_policy" {
  count = var.secret_method == "secretsmanager" && var.secret_rotation ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "basic" {
  count = var.secret_method == "secretsmanager" && var.secret_rotation ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
      "secretsmanager:GetRandomPassword"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "secrets" {
  count = var.secret_method == "secretsmanager" && var.secret_rotation ? 1 : 0

  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage"
    ]
    resources = ["arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*"]
  }
}

data "aws_iam_policy_document" "kms" {
  count = var.secret_method == "secretsmanager" && var.secret_rotation ? 1 : 0

  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey"
    ]
    resources = ["arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"]
  }
}

resource "aws_lambda_function" "lambda_rotate_secrets" {
  count = var.secret_method == "secretsmanager" && var.secret_rotation ? 1 : 0

  function_name    = "lambda-rotate-secrets-${var.environment_name}-${var.identifier}-${var.user}"
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
      EXCLUDE_CHARACTERS       = "/@\"'\\"
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${data.aws_region.current.name}.amazonaws.com"
    }
  }
}

resource "aws_lambda_permission" "allow_secrets_manager" {
  count = var.secret_method == "secretsmanager" && var.secret_rotation ? 1 : 0

  statement_id  = "AllowExecutionFromSecretManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_rotate_secrets[0].function_name
  principal     = "secretsmanager.amazonaws.com"
}
