module "terraform_state_backend" {
  source = "cloudposse/tfstate-backend/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "1.5.0"
  name    = "ryan-terraform-state-backend"

  # terraform_backend_config_file_path = "."
  # terraform_backend_config_file_name = "backend.tf"
  force_destroy = false
}

module "terraform_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.44.0"

  trusted_role_arns = [
    data.aws_iam_user.ryan.arn,
    # allow to assume to itself before removing usage of profiles and 
    # credentials in the provider.tf and backend.tf
    "arn:aws:iam::${data.aws_caller_identity.current.id}:root"
  ]

  create_role = true

  role_name         = "Terraform"
  role_requires_mfa = false

  custom_role_policy_arns = [
    data.aws_iam_policy.admin.arn
  ]
}

module "terraform_backend_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.44.0"

  trusted_role_arns = [
    # data.aws_iam_user.ryan.arn,
    module.terraform_role.iam_role_arn
  ]
  create_role = true

  role_name         = "TerraformBackend"
  role_requires_mfa = false

  inline_policy_statements = [
    {
      effect = "Allow"
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ]
      resources = [
        "${module.terraform_state_backend.s3_bucket_arn}",
        "${module.terraform_state_backend.s3_bucket_arn}/*"
      ]
    },
    {
      effect = "Allow"
      actions = [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ]
      resources = [
        "${module.terraform_state_backend.dynamodb_table_arn}"
      ]
    }
  ]

}

module "allow_assume_to_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 5.44.0"

  name = "TerraformRoles"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect : "Allow",
        Action : "sts:AssumeRole",
        Resource : "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_terraform_to_user" {
  user       = data.aws_iam_user.ryan.user_name
  policy_arn = module.allow_assume_to_role.arn
}

