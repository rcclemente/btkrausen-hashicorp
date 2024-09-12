data "aws_caller_identity" "current" {}

data "aws_iam_user" "ryan" {
  user_name = "ryan"
}

data "aws_iam_policy" "admin" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
