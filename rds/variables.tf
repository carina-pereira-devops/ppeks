variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC onde o RDS será criado"
}

variable "private_subnets" {
  type        = list(string)
  description = "Subnets privadas para o db subnet group"
}

variable "project_name" {
  type        = string
}

