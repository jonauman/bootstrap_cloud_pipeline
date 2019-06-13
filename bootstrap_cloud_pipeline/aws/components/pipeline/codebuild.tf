resource "aws_s3_bucket" "codebuild" {
  bucket = "codebuild-${var.app_repo_name}-${var.environment}-${md5(data.aws_caller_identity.current.account_id)}"
  acl    = "private"
}

resource "aws_iam_role" "codebuild" {
  name = "codebuild-${var.app_repo_name}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codebuild.arn}",
        "${aws_s3_bucket.codebuild.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:*"
      ],
      "Resource": [
        "${aws_codecommit_repository.app_repo.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*"
      ],
      "Resource": [
        "${aws_ecr_repository.app_repo.arn}"
      ]
    }
  ]
}
POLICY

}

resource "aws_codebuild_project" "codebuild_project" {
    name          = "codebuild-${var.app_repo_name}-${var.environment}"
    description   = "codebuild-${var.app_repo_name}-${var.environment} project"
    build_timeout = "5"
    service_role  = aws_iam_role.codebuild.arn

    artifacts {
    type = "NO_ARTIFACTS"
    }

    cache {
    type     = "S3"
    location = aws_s3_bucket.codebuild.bucket
    }

    environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
        environment_variable {
        name  = "IMAGE_REPO_NAME"
        value = aws_ecr_repository.app_repo.name
        }

        environment_variable {
        name  = "IMAGE_TAG"
        value = "latest"
        }

        environment_variable {
        name  = "AWS_DEFAULT_REGION"
        value = "eu-west-2"
        }

        environment_variable {
        name  = "AWS_ACCOUNT_ID"
        value = "${data.aws_caller_identity.current.account_id}"
        }

    }

    source {
        type            = "CODECOMMIT"
        location        = "${aws_codecommit_repository.app_repo.clone_url_http}"
        git_clone_depth = 1
    }

    tags = {
        "Environment" = var.environment
    }
}

