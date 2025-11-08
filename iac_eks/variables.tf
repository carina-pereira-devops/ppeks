# Definição e inicialização das variáveis do módulo principal, quando CiCd no github
variable "cidr_block" {
  type        = string
  description = "Range de IPs utilizado na VPC"
  #default = "10.0.0.0/16"
}

variable "project_name" {
  type        = string
  description = "Nome do Projeto"
  #default = "ekspp"
}

variable "region" {
  type        = string
  description = "Região da AWS"
}

variable "tags" {
  # Variável com conjunto de pares chave-valor 
  type        = map(any)
  description = "Tags pertencentes aos recursos criados"
}