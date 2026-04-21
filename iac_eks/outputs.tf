output "vpc_id" {
  value = module.eks_network.vpc_id
}

output "subnet_priv_1a" {
  value = module.eks_network.subnet_priv_1a
}

output "subnet_priv_1b" {
  value = module.eks_network.subnet_priv_1b
}