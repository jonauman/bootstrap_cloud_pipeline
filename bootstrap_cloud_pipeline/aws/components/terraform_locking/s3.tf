resource "aws_s3_bucket" "s3_remote_state" {
  bucket = "tfstate-${var.environment}-${md5(data.aws_caller_identity.current.account_id)}"
  acl    = "bucket-owner-full-control"

  tags = {
    Name        = "tfstate-${var.environment}-${md5(data.aws_caller_identity.current.account_id)}"
    Environment = var.environment
  }

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

}

