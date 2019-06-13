resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "tfstate-lock-${var.environment}"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table for ${var.environment}"
  }
}

