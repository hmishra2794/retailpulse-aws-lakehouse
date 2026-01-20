resource "aws_glue_job" "silver_to_gold" {
  name     = "retailpulse-silver-to-gold"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.lake["raw"].bucket}/glue/jobs/silver_to_gold.py"
  }

  default_arguments = {
    "--SILVER_PATH"    = "s3://${aws_s3_bucket.lake["silver"].bucket}/orders/"
    "--GOLD_FACT_PATH" = "s3://${aws_s3_bucket.lake["gold"].bucket}/fact_orders/"
    "--GOLD_AGG_PATH"  = "s3://${aws_s3_bucket.lake["gold"].bucket}/agg_daily_revenue/"
    "--job-language"   = "python"
  }

  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
}
