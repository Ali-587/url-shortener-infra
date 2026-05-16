data "aws_caller_identity" "current" {}

locals {
  name = "${var.env_vars.namespace}-${var.env_vars.stage}"
}

data "archive_file" "lambda_placeholder" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-placeholder"
  output_path = "${path.module}/lambda-placeholder.zip"
}

