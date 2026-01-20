############################
# EventBridge Bus
############################
resource "aws_cloudwatch_event_bus" "retailpulse_bus" {
  name = "retailpulse-bus"
}

############################
# SQS + DLQ for ingestion buffering
############################
resource "aws_sqs_queue" "ingest_dlq" {
  name                      = "retailpulse-ingest-dlq"
  message_retention_seconds = 1209600 # 14 days
}

resource "aws_sqs_queue" "ingest_queue" {
  name                       = "retailpulse-ingest-queue"
  visibility_timeout_seconds = 60

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.ingest_dlq.arn
    maxReceiveCount     = 3
  })
}
