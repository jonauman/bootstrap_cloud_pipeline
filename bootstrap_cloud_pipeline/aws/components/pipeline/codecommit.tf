resource "aws_codecommit_repository" "app_repo" {
  repository_name = var.app_repo_name
  description     = "${var.app_repo_name} Repository"
  default_branch  = "master"
}

