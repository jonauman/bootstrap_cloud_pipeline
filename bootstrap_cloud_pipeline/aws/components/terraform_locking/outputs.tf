output "tfstatelock_s3_bucket_name" {
    value = "${aws_s3_bucket.s3_remote_state.id}"
}

output "tfstatelock_dynamodb_table" {
    value = "${aws_dynamodb_table.dynamodb-terraform-state-lock.id}"
}
