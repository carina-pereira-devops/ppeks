variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type        = string
  default     = vpc-01a096d1a354420f6 # Automatizar essa info, para não ter Id dinâmico
  description = "VPC onde o RDS será criado"
}

variable "private_subnets" {
  type        = list(string)
  default     = ["subnet-0ef720bd932deb291", "subnet-070b36a9167e55fd9"] # Automatizar essa info, para não ter Id dinâmico
  description = "Subnets privadas para o db subnet group"
}

variable "project_name" {
  type        = string
}

