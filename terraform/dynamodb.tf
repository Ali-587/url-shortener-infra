resource "aws_dynamodb_table" "urls" {
  name         = "${local.name}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "shortCode"

  attribute {
    name = "shortCode"
    type = "S"
  }

  tags = {
    Project = local.name
  }
}