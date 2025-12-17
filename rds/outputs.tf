output "rds_endpoint" {
  description = "Endpoint do RDS Postgres"
  value       = aws_db_instance.postgres.address
}

output "rds_db_name" {
  description = "Nome do banco no RDS"
  value       = aws_db_instance.postgres.db_name
}
