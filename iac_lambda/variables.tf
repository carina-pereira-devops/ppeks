variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "ppeks"
}

variable "ssm_path_db_username" {
  description = "Caminho SSM do username do banco"
  type        = string
  default     = "/db/username"
}

variable "ssm_path_db_password" {
  description = "Caminho SSM do password do banco"
  type        = string
  default     = "/db/password"
}
