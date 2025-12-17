output "rds_endpoint" {
  description = "Endpoint DNS do RDS"
  value       = aws_db_instance.this.address
}

output "rds_db_name" {
  description = "Nome do database"
  value       = aws_db_instance.this.name
}
