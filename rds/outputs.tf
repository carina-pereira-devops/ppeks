# Outputs do módulo RDS, para expor os dados necessários para outros módulos (como o EKS) ou para o usuário final.

# Redes
output "vpc_id" {
  value = module.eks_network.vpc_id
}

output "subnet_priv_1a" {
  value = module.eks_network.subnet_priv_1a
}

output "subnet_priv_1b" {
  value = module.eks_network.subnet_priv_1b
}

# Dados do Banco
output "rds_endpoint" {
  description = "Endpoint do RDS Postgres"
  value       = aws_db_instance.postgres.address
}

output "rds_db_name" {
  description = "Nome do banco no RDS"
  value       = aws_db_instance.postgres.db_name
}
