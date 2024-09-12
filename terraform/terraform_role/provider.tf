provider "aws" {
  region = "us-east-1"
  # configure using aws-vault 
  # https://medium.com/@alfonso_cabrera/terraform-security-with-aws-vault-901b64c72003
  # shared_credentials_files = ["~/.aws/personal_credentials"]
  # profile                  = "ryan"

  assume_role {
    role_arn = "arn:aws:iam::038462749730:role/Terraform"
  }
  # command 
  #  aws-vault exec mainUser -- terraform plan


  default_tags {
    tags = {
      owner     = "ryan"
      terraform = "true"
    }
  }
}
