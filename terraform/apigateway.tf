resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.name}-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
    max_age       = 300
  }

  tags = {
    Project = local.name
  }
}

resource "aws_apigatewayv2_authorizer" "cloudfront_header_authorizer" {
  name                              = "${local.name}-cloudfront-header-authorizer"
  api_id                            = aws_apigatewayv2_api.http_api.id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = aws_lambda_function.authorizer.invoke_arn
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true

  identity_sources = [
    "$request.header.x-cloudfront-secret"
  ]
}

resource "aws_apigatewayv2_integration" "backend_lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.backend.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.cloudfront_header_authorizer.id
}

resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /"

  target = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.cloudfront_header_authorizer.id
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Project = local.name
  }
}

resource "aws_lambda_permission" "api_gateway_backend" {
  statement_id  = "AllowHttpApiGatewayInvokeBackend"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_authorizer" {
  statement_id  = "AllowHttpApiGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.cloudfront_header_authorizer.id}"
}

