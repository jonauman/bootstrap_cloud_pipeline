data "terraform_remote_state" "terraform_locking" {
  backend = "s3"
  config = {
    bucket = "tfstate-${var.environment}-${md5(data.aws_caller_identity.current.account_id)}"
    region = "eu-west-2"
    key    = "terraform_locking.tfstate"
  }
}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {
}

