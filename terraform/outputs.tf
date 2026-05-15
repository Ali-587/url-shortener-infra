output "api_gateway_url" {
  description = "Raw API Gateway URL. Direct access should be blocked by authorizer."
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "frontend_bucket_name" {
  description = "S3 bucket name for frontend"
  value       = aws_s3_bucket.frontend.bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_url" {
  description = "Public frontend and API URL"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "lambda_function_name" {
  description = "Backend Lambda function name"
  value       = aws_lambda_function.backend.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.urls.name
}

output "cloudfront_waf_acl_arn" {
  description = "CloudFront WAF ACL ARN"
  value       = aws_wafv2_web_acl.cloudfront_waf.arn
}

output "ssm_cloudfront_secret_parameter_name" {
  description = "SSM parameter name storing CloudFront secret header"
  value       = aws_ssm_parameter.cloudfront_secret.name
}