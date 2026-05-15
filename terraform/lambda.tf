resource "aws_lambda_function" "backend" {
  function_name = "${local.name}-backend"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "src/app.handler"
  runtime       = var.lambda_runtime
  architectures = ["arm64"]

  filename         = data.archive_file.lambda_placeholder.output_path
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.urls.name
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy
  ]

  tags = {
    Project = local.name
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash
    ]
  }
}
