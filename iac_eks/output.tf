# Alimentar RDS

output "eks_vpc_id" {
  value = module.network.vpc_id
}

output "eks_private_subnets" {
  description = "Subnets privadas usadas pelo EKS/RDS"
  value = [
    module.network.subnet_priv_1a,
    module.network.subnet_priv_1b,
  ]
}

output "project_name" {
  value = module.network.project_name
}
