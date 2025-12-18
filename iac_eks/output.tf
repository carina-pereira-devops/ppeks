# Alimentar RDS

output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnets" {
  value = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1b.id,
  ]
}
