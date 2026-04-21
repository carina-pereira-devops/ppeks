# ==============================================================
# IAM Role para a Lambda
# ==============================================================

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = {
    Project = var.project_name
  }
}

# Permissão básica: CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permissão de leitura no SSM (já usado no projeto)
resource "aws_iam_role_policy_attachment" "lambda_ssm" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# ==============================================================
# Empacotamento do código Python → ZIP
# ==============================================================

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# ==============================================================
# Função Lambda
# ==============================================================

resource "aws_lambda_function" "ppeks_health" {
  function_name    = "${var.project_name}-health-check"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      PROJECT_NAME         = var.project_name
      SSM_PATH_DB_USERNAME = var.ssm_path_db_username
      SSM_PATH_DB_PASSWORD = var.ssm_path_db_password
      DB_HOST              = "see-rds-outputs"
    }
  }

  tags = {
    Project = var.project_name
  }
}

# ==============================================================
# Function URL — expõe como aplicação web (sem API Gateway)
# Necessário para concluir atividade AWS: "aplicação web com Lambda"
# ==============================================================

resource "aws_lambda_function_url" "ppeks_health_url" {
  function_name      = aws_lambda_function.ppeks_health.function_name
  authorization_type = "NONE"

  cors {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    max_age       = 300
  }
}

# ==============================================================
# EventBridge — executa a cada 5 minutos (mantém Lambda quente)
# ==============================================================

resource "aws_cloudwatch_event_rule" "every_5min" {
  name                = "${var.project_name}-health-schedule"
  description         = "Executa o health check Lambda a cada 5 minutos"
  schedule_expression = "rate(5 minutes)"

  tags = {
    Project = var.project_name
  }
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule = aws_cloudwatch_event_rule.every_5min.name
  arn  = aws_lambda_function.ppeks_health.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ppeks_health.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_5min.arn
}
