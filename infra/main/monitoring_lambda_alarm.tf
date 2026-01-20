resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "retailpulse-lambda-errors"
  alarm_description   = "Lambda ingestor has errors > 0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0

  dimensions = {
    FunctionName = aws_lambda_function.ingestor.function_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
