############################
# EventBridge Rule -> SQS Target
############################
resource "aws_cloudwatch_event_rule" "ingest_all_events" {
  name           = "retailpulse-ingest-all"
  description    = "Route all retailpulse events from bus to SQS ingest queue"
  event_bus_name = aws_cloudwatch_event_bus.retailpulse_bus.name

  event_pattern = jsonencode({
    "source" : ["retailpulse"]
  })
}

# Allow EventBridge to send messages to the SQS queue
resource "aws_sqs_queue_policy" "ingest_queue_policy" {
  queue_url = aws_sqs_queue.ingest_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridgeSendMessage"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.ingest_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.ingest_all_events.arn
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_event_target" "to_sqs" {
  event_bus_name = aws_cloudwatch_event_bus.retailpulse_bus.name
  rule           = aws_cloudwatch_event_rule.ingest_all_events.name
  arn            = aws_sqs_queue.ingest_queue.arn
}
