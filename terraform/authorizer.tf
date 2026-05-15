data "archive_file" "authorizer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/authorizer"
  output_path = "${path.module}/authorizer.zip"
}

resource "aws_iam_role" "authorizer_exec" {
  name = "${local.name}-authorizer-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = local.name
  }
}

resource "aws_iam_role_policy_attachment" "authorizer_logs" {
  role       = aws_iam_role.authorizer_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "authorizer" {
  function_name = "${local.name}-authorizer"
  role          = aws_iam_role.authorizer_exec.arn
  handler       = "src/authorizer.handler"
  runtime       = var.lambda_runtime
  architectures = ["arm64"]

  filename         = data.archive_file.authorizer_zip.output_path
  source_code_hash = data.archive_file.authorizer_zip.output_base64sha256

  timeout     = 5
  memory_size = 128

  environment {
    variables = {
      CLOUDFRONT_SECRET_HEADER_NAME  = "x-cloudfront-secret"
      CLOUDFRONT_SECRET_HEADER_VALUE = random_password.cloudfront_secret.result
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.authorizer_logs
  ]

  tags = {
    Project = local.name
  }
}