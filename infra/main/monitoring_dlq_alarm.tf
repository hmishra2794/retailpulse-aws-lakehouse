resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "retailpulse-dlq-messages"
  alarm_description   = "DLQ has messages > 0 (ingestion failures)"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0

  dimensions = {
    QueueName = aws_sqs_queue.ingest_dlq.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
