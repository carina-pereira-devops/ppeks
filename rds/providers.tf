terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
    backend "s3" {
    bucket = "arquivo-de-estado"
    key    = "rds/terraform.tfstate"
    region = "us-east-1"    
  }
}

provider "aws" {
  region = var.region
}
