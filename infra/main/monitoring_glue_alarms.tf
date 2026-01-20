resource "aws_cloudwatch_metric_alarm" "glue_raw_to_silver_failed" {
  alarm_name          = "retailpulse-glue-raw-to-silver-failed"
  alarm_description   = "Glue job raw_to_silver failed runs > 0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "GlueJobRunsFailed"
  namespace           = "AWS/Glue"
  period              = 300
  statistic           = "Sum"
  threshold           = 0

  dimensions = {
    JobName = aws_glue_job.raw_to_silver.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "glue_silver_to_gold_failed" {
  alarm_name          = "retailpulse-glue-silver-to-gold-failed"
  alarm_description   = "Glue job silver_to_gold failed runs > 0"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "GlueJobRunsFailed"
  namespace           = "AWS/Glue"
  period              = 300
  statistic           = "Sum"
  threshold           = 0

  dimensions = {
    JobName = aws_glue_job.silver_to_gold.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
