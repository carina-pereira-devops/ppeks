resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project_name}-cluster"
  # Amazon Resource Name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      var.public_subnet_1a,
      var.public_subnet_1b
    ]
    # Acesso ao endpoint da API do Kubernetes via rede privada
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP" # ou "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Forçando uma dependência
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_attachment
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cluster"
    }
  )
}

# Permissões da Role de Criação do Cluster
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::749000351410:role/github-carina-devops-pipe"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::749000351410:role/github-carina-devops-pipe"
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# Permissões do meu usuário Local:
resource "aws_eks_access_entry" "devops" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::749000351410:user/devops"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "devops_admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = "arn:aws:iam::749000351410:user/devops"

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}



