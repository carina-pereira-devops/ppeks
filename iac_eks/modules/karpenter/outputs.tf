output "karpenter_node_role_arn" {
  value       = aws_iam_role.karpenter_node.arn
  description = "ARN da IAM Role dos nodes criados pelo Karpenter"
}

output "karpenter_controller_role_arn" {
  value       = aws_iam_role.karpenter_controller.arn
  description = "ARN da IAM Role do controller do Karpenter (IRSA)"
}

output "karpenter_interruption_queue" {
  value       = aws_sqs_queue.karpenter_interruption.name
  description = "Nome da fila SQS de interrupção de spot"
}
