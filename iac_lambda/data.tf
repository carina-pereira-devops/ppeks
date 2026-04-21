# iac_lambda/data.tf
data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    bucket = "tfstate-ppeks"
    key    = "rds/terraform.tfstate"
    region = "us-east-1"
  }
}