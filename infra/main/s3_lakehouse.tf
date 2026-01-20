locals {
  lake_buckets = {
    raw    = "retailpulse-raw-206470327951"
    silver = "retailpulse-silver-206470327951"
    gold   = "retailpulse-gold-206470327951"
    athena = "retailpulse-athena-results-206470327951"
  }
}

resource "aws_s3_bucket" "lake" {
  for_each = local.lake_buckets
  bucket   = each.value
}

resource "aws_s3_bucket_versioning" "lake" {
  for_each = aws_s3_bucket.lake
  bucket   = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lake" {
  for_each = aws_s3_bucket.lake
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "lake" {
  for_each = aws_s3_bucket.lake
  bucket   = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
