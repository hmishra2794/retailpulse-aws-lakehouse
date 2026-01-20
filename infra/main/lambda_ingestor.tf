resource "aws_lambda_function" "ingestor" {
  function_name = "retailpulse-ingestor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.handler"
  runtime       = "python3.12"

  filename         = "${path.module}/../../build/lambda_ingestor/lambda_ingestor.zip"
  source_code_hash = filebase64sha256("${path.module}/../../build/lambda_ingestor/lambda_ingestor.zip")


  timeout     = 30
  memory_size = 256

  environment {
    variables = {
      RAW_BUCKET = aws_s3_bucket.lake["raw"].bucket
    }
  }

  tags = {
    project    = "retailpulse"
    env        = "dev"
    managed_by = "terraform"
  }
}
