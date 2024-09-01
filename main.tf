provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["/Users/gabri/.aws/credentials"]
}

resource "aws_iam_role" "lambda_role"{
  name = "lambda_notification_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        Resource = "*",
      },
      {
        Effect   = "Allow",
        Action   = [
          "ses:SendEmail",
          "ses:SendRawEmail",
        ],
        Resource = "*",
      },
    ],
  })
}

resource "aws_lambda_function" "notify" {
  function_name = "notify_on_push"
  role = aws_iam_role.lambda_role.arn
  handler = "index.handler"
  runtime = "nodejs18.x"
  filename = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")
  environment {
    variables = {
      TO_EMAIL             = var.to_email
    }
  }
}
