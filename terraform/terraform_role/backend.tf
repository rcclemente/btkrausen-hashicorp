terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "ryan-terraform-state-backend"
    key    = "terraform.tfstate"
    assume_role = {
      role_arn = "arn:aws:iam::038462749730:role/Terraform"
    }
    # shared_credentials_files = ["~/.aws/personal_credentials"]
    # profile                  = "ryan"

    encrypt        = "true"
    dynamodb_table = "ryan-terraform-state-backend-lock"
  }
}
