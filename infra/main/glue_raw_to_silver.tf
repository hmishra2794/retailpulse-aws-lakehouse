resource "aws_glue_job" "raw_to_silver" {
  name     = "retailpulse-raw-to-silver"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.lake["raw"].bucket}/glue/jobs/raw_to_silver.py"
  }

  default_arguments = {
    "--RAW_PATH"     = "s3://${aws_s3_bucket.lake["raw"].bucket}/events/"
    "--SILVER_PATH"  = "s3://${aws_s3_bucket.lake["silver"].bucket}/orders/"
    "--job-language" = "python"
  }

  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  tags = {
    project = "retailpulse"
    env     = "dev"
  }
}
