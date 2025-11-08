# Versão atual dos Providers validadas!
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.32.0"
    }
  }
  
  backend "s3" {
    bucket = "arquivo-de-estado-tf"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"    
  }
}

provider "aws" {
  region = var.region
}

