resource "aws_ssm_parameter" "cloudfront_secret" {
  name        = "/${local.name}/cloudfront-secret"
  description = "Secret header value used between CloudFront and API Gateway authorizer"
  type        = "SecureString"
  value       = random_password.cloudfront_secret.result

  tags = {
    Project = local.name
  }
}