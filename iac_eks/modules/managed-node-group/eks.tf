resource "aws_eks_node_group" "eks_managed_node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.project_name}-nodegroup"
  node_role_arn   = aws_iam_role.eks_eks_role.arn
  instance_types  = ["t3.medium"] # Subindo de t3.micro — Karpenter precisa de CPU/mem

  subnet_ids = [
    var.subnet_private_1a,
    var.subnet_private_1b
  ]

  tags = merge(var.tags, { Name = "${var.project_name}-nodegroup" })

  scaling_config {
    desired_size = 2
    max_size     = 2 # MGN fixo em 2 — Karpenter escala o resto
    min_size     = 2
  }

  # ============================================================
  # TAINT DE SISTEMA — garante que APENAS pods de sistema rodem
  # aqui: kube-proxy, aws-node, coredns, karpenter
  # Qualquer outro pod sem toleration vai para nodes do Karpenter
  # ============================================================
  taint {
    key    = "node-role"
    value  = "system"
    effect = "NO_SCHEDULE" # não agenda pods sem toleration
  }

  labels = {
    "node-role" = "system"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_eks_role_attachment_worker,
    aws_iam_role_policy_attachment.eks_eks_role_attachment_ecr,
    aws_iam_role_policy_attachment.eks_eks_role_attachment_cni
  ]
}
