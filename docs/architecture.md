# RetailPulse AWS – Architecture

## Data Flow (Near Real-Time → Lakehouse → Analytics)

Event Producer
  → EventBridge (custom bus: retailpulse-bus)
    → Rule (source=retailpulse)
      → SQS (retailpulse-ingest-queue) + DLQ (retailpulse-ingest-dlq)
        → Lambda (retailpulse-ingestor)
          → S3 RAW (retailpulse-raw-<account>) [JSON, partitioned by event_type/dt]

Glue Job 1: raw_to_silver
  S3 RAW → S3 SILVER (Parquet, schema-enforced, partitioned by event_date)

Glue Job 2: silver_to_gold
  SILVER → GOLD fact_orders (Parquet, partitioned by event_date)
  SILVER → GOLD agg_daily_revenue (Parquet, partitioned by event_date)

Athena
  SQL queries on GOLD tables (database: retailpulse)
  Results stored in S3 athena-results bucket

## Monitoring
- CloudWatch Alarm: DLQ messages > 0 → SNS retailpulse-alerts
- CloudWatch Alarm: Lambda Errors > 0 → SNS retailpulse-alerts
- CloudWatch Alarm: Glue job failed runs > 0 → SNS retailpulse-alerts
