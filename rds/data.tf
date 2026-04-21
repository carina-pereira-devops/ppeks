# recuperando o state do EKS para pegar o VPC e subnets
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "tfstate-ppeks"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}