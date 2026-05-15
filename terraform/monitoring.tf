resource "aws_sns_topic" "alerts" {
  name = "${local.name}-alerts"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "backend_lambda_errors" {
  alarm_name          = "${local.name}-backend-lambda-errors"
  alarm_description   = "Triggers when backend Lambda has one or more errors."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  statistic           = "Sum"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.backend.function_name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "authorizer_lambda_errors" {
  alarm_name          = "${local.name}-authorizer-lambda-errors"
  alarm_description   = "Triggers when Lambda authorizer has one or more errors."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  statistic           = "Sum"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.authorizer.function_name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_lambda_throttles" {
  alarm_name          = "${local.name}-backend-lambda-throttles"
  alarm_description   = "Triggers when backend Lambda is throttled."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  statistic           = "Sum"
  namespace           = "AWS/Lambda"
  metric_name         = "Throttles"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.backend.function_name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}