resource "aws_ssm_parameter" "db_username" {
  name        = "/db/username"
  description = "User da aplicação para o RDS"
  type        = "String"
  value       = "matthias"
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/db/password"
  description = "Senha da aplicação para o RDS"
  type        = "SecureString"
  value       = "password"  # ou um valor inicial

  lifecycle {
    ignore_changes = [value]
  }
}
