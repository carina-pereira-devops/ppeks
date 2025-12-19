# Alimentar RDS

output "eks_vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "eks_private_subnets" {
  description = "Subnets privadas usadas pelo EKS/RDS"
  value = [ aws_subnet.eks_subnet_private_1a.id, aws_subnet.eks_subnet_private_1b.id ]
}

output "project_name" {
  value = "ppeks"
}
