RetailPulse AWS – Near Real-Time Lakehouse

(Event-Driven Data Engineering on AWS)

RetailPulse is a near real-time, event-driven data lakehouse built on AWS.
It ingests streaming business events, stores immutable raw data, performs distributed ETL using Spark, and enables analytics using serverless SQL — all provisioned via Terraform.
This project demonstrates production-grade data engineering principles: decoupling, fault tolerance, scalability, and cost efficiency.

Architecture

📄 See detailed diagram: docs/architecture.md

Flow:
	
EventBridge
   ↓
SQS (+ DLQ)
   ↓
Lambda (Ingestor)
   ↓
S3 RAW
   ↓
Glue (RAW → SILVER)
   ↓
Glue (SILVER → GOLD)
   ↓
Athena (Analytics)


Why This Architecture?

This architecture is intentionally designed to reflect real-world, production data platforms:
	EventBridge decouples event producers from consumers
	SQS provides buffering, retry handling, and backpressure protection
	Lambda enables serverless ingestion without managing servers
	S3 Lakehouse offers durable, low-cost, scalable storage
	Glue (Spark) handles distributed ETL at scale
	Athena enables serverless analytics without data movement
	Terraform ensures reproducible, auditable infrastructure
	CloudWatch + SNS provide operational visibility and alerting

The design prioritizes reliability, scalability, and operational simplicity over complexity.


AWS Services Used

	Amazon S3 – RAW / SILVER / GOLD layers + Athena query results
	Amazon EventBridge – Custom event bus + routing rules
	Amazon SQS – Ingestion queue + Dead Letter Queue
	AWS Lambda – SQS consumer → RAW S3 writer
	AWS Glue – Spark ETL jobs (RAW → SILVER → GOLD)
	Amazon Athena – Serverless SQL analytics
	Amazon CloudWatch – Metrics & alarms
	Amazon SNS – Alert notifications
	AWS IAM – Roles & least-privilege policies
	Terraform – Infrastructure as Code + remote state


Data Lake Layout

RAW Layer (Immutable JSON)
	s3://retailpulse-raw-<account>/events/
  		└── event_type=<type>/
      			└── dt=<YYYY-MM-DD>/
          			└── <event_id>.json


SILVER Layer (Cleaned Parquet)
	s3://retailpulse-silver-<account>/orders/
  		└── event_date=<YYYY-MM-DD>/
      			└── *.parquet


GOLD Layer (Analytics-Ready)

Fact Table
	s3://retailpulse-gold-<account>/fact_orders/
  		└── event_date=<YYYY-MM-DD>/
      			└── *.parquet

Aggregates
	s3://retailpulse-gold-<account>/agg_daily_revenue/
  		└── event_date=<YYYY-MM-DD>/
      			└── *.parquet



Failure Handling & Reliability

	SQS DLQ captures failed ingestion events
	Lambda retries handled via SQS visibility timeout
	Glue job failures tracked via CloudWatch metrics
	SNS alerts notify on ingestion or ETL failures
	RAW data is immutable, enabling safe reprocessing
	Terraform remote state (S3 + DynamoDB) ensures safe infrastructure changes

How to Deploy (Terraform)

Prerequisites
	AWS CLI configured with profile retailpulse
	Terraform installed

Bootstrap (Remote State)
	cd infra/bootstrap
	terraform init
	terraform apply -auto-approve

Main Infrastructure
	cd ../main
	terraform init
	terraform apply -auto-approve

   Note: Terraform uses remote state (S3 + DynamoDB) to enable safe, repeatable deployments.

How to Test the Pipeline

	1️ Send a Test Event
		aws events put-events --profile retailpulse --entries '[
			  {
    				"Source": "retailpulse",
    				"DetailType": "order_created",
    				"Detail": "{\"event_id\":\"test-100\",\"event_type\":\"order_created\",\"event_ts\":\"2026-01-14T20:00:00Z\",\"customer_id\":\"c100\",\"order_id\":\"o100\",\"amount\":123.0}",
    				"EventBusName":"retailpulse-bus"
  			}
			]'


	2️ Verify RAW Data
		aws s3 ls s3://retailpulse-raw-<account>/events/ --recursive --profile retailpulse

	3️ Run Glue ETL Jobs
		aws glue start-job-run --job-name retailpulse-raw-to-silver --profile retailpulse
		aws glue start-job-run --job-name retailpulse-silver-to-gold --profile retailpulse

	 Query with Athena
		SELECT event_date, daily_revenue
		FROM retailpulse.agg_daily_revenue
		ORDER BY event_date;

Monitoring & Alerts

	CloudWatch alarms notify SNS topic retailpulse-alerts when:
	DLQ messages > 0
	Lambda ingestion errors > 0
	Glue job failures > 0

	This ensures fast detection and operational visibility.

Possible Enhancements

	Glue Crawlers for schema discovery
	Incremental Glue jobs with bookmarks
	Event schema validation (Glue Schema Registry)
	CI/CD for Terraform (GitHub Actions)
	Cost optimization via partition pruning

Repository

	GitHub:
		👉 https://github.com/hmishra2794/retailpulse-aws-lakehouse
