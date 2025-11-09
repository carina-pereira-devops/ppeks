resource "aws_eks_node_group" "eks_managed_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-nodegroup"
  node_role_arn   = aws_iam_role.eks_eks_role.arn
  #instance_types  = ["t3.medium"]
  subnet_ids = [
    #Subnets privedas
    var.subnet_private_1a,
    var.subnet_private_1b
  ]
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-nodegroup"
    }
  )

# Argo consumindo muitos recursos, ajustar quantidade de máquinas? Refatorar código para especificar outra família de instâncias.
# Obs.: Prometheus Statefulset, vai subir em todos os Nodes, o que pode consumir recursos desnecessários
  scaling_config {

    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_eks_role_attachment_worker,
    aws_iam_role_policy_attachment.eks_eks_role_attachment_ecr,
    aws_iam_role_policy_attachment.eks_eks_role_attachment_cni
  ]
}