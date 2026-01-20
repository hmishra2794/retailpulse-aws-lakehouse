# RetailPulse AWS – Near Real-Time Lakehouse (S3 + Glue + Athena)

RetailPulse is an AWS-based data engineering project that ingests events in near real-time and builds a Lakehouse on S3 using Glue ETL and Athena analytics.

## Architecture
See: `docs/architecture.md`

**Flow**
EventBridge → SQS (+ DLQ) → Lambda → S3 RAW → Glue (RAW→SILVER) → Glue (SILVER→GOLD) → Athena (SQL)

## AWS Services Used
- S3 (RAW/SILVER/GOLD + Athena results)
- EventBridge (custom bus + rule)
- SQS (queue + DLQ)
- Lambda (SQS consumer → S3 RAW writer)
- Glue (Spark ETL jobs)
- Athena (serverless SQL)
- CloudWatch + SNS (monitoring & alerts)
- IAM (roles/policies)
- Terraform (IaC + remote state)

## Data Layout
### RAW (JSON)
`s3://retailpulse-raw-<account>/events/event_type=<type>/dt=<YYYY-MM-DD>/<event_id>.json`

### SILVER (Parquet)
`s3://retailpulse-silver-<account>/orders/event_date=<YYYY-MM-DD>/*.parquet`

### GOLD (Parquet)
- Fact: `s3://retailpulse-gold-<account>/fact_orders/event_date=<YYYY-MM-DD>/*.parquet`
- Aggregates: `s3://retailpulse-gold-<account>/agg_daily_revenue/event_date=<YYYY-MM-DD>/*.parquet`

## How to Deploy (Terraform)
> Prereq: AWS CLI configured with profile `retailpulse`

```bash
cd infra/bootstrap
terraform init
terraform apply -auto-approve

cd ../main
terraform init
terraform apply -auto-approve




How to Test

1) Send an event
   
   aws events put-events --profile retailpulse --entries '[
  {
    "Source": "retailpulse",
    "DetailType": "order_created",
    "Detail": "{\"event_id\":\"test-100\",\"event_type\":\"order_created\",\"event_ts\":\"2026-01-14T20:00:00Z\",\"customer_id\":\"c100\",\"order_id\":\"o100\",\"amount\":123.0}",
    "EventBusName":"retailpulse-bus"
  }
]'

2) Verify RAW landed in S3

   aws s3 ls s3://retailpulse-raw-<account>/events/ --recursive --profile retailpulse

3) Run Glue Jobs
   
   aws glue start-job-run --job-name retailpulse-raw-to-silver --profile retailpulse
   aws glue start-job-run --job-name retailpulse-silver-to-gold --profile retailpulse

4) Athena example query

   SELECT event_date, daily_revenue
   FROM retailpulse.agg_daily_revenue
   ORDER BY event_date;

Monitoring

  CloudWatch alarms notify SNS topic retailpulse-alerts for:
	DLQ messages > 0
	Lambda errors > 0
	Glue job failed runs > 0

