variable "project_name" {
  type        = string
  description = "Nome do Projeto"
}

variable "tags" {
  type        = map(any)
  description = "Tags pertencentes aos recursos criados"
}

variable "cluster_name" {
  type        = string
  description = "Nome do Cluster EKS"
}

variable "cluster_endpoint" {
  type        = string
  description = "Endpoint da API do Cluster EKS"
}

variable "oidc" {
  type        = string
  description = "URL do OIDC Provider do Cluster (ex: https://oidc.eks.us-east-1.amazonaws.com/id/...)"
}

variable "subnet_private_1a" {
  type        = string
  description = "ID da Subnet Privada AZ us-east-1a"
}

variable "subnet_private_1b" {
  type        = string
  description = "ID da Subnet Privada AZ us-east-1b"
}
