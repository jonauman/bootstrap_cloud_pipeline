#terraform{
#    backend "s3" {
#        bucket          = "tfstate-demo-004d56924dd6dbf8e4a108fabd4ec124"
#        region          = "eu-west-2"
#        key             = "terraform_locking.tfstate"
#        encrypt         = "true"
#        dynamodb_table  = "tfstate-lock-demo"
#        acl             = "bucket-owner-full-control"
#    }
#}
