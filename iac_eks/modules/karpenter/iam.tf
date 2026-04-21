# ============================================================
# IAM — IRSA Role para o Karpenter Controller
# ============================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  oidc_id = replace(var.oidc, "https://", "")
}

# ---- IAM Role do Karpenter Controller (IRSA) ----
resource "aws_iam_role" "karpenter_controller" {
  name = "${var.project_name}-karpenter-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_id}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_id}:aud" = "sts.amazonaws.com"
            "${local.oidc_id}:sub" = "system:serviceaccount:kube-system:karpenter"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.project_name}-karpenter-controller" })
}

resource "aws_iam_policy" "karpenter_controller" {
  name = "${var.project_name}-karpenter-controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # --------------------------------------------------------
      # EKS — detectar CIDR do cluster e configurações de rede
      # OBRIGATÓRIO no Karpenter v1.x — sem isso: "Failed to
      # detect the cluster CIDR" e EC2NodeClass fica NotReady
      # --------------------------------------------------------
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "arn:aws:eks:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
      },

      # --------------------------------------------------------
      # EC2 — criar e gerenciar instâncias (spot + on-demand)
      # --------------------------------------------------------
      {
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:DeleteLaunchTemplate",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },

      # --------------------------------------------------------
      # EC2 — spot instance requests
      # --------------------------------------------------------
      {
        Effect = "Allow"
        Action = [
          "ec2:RequestSpotInstances",
          "ec2:CancelSpotInstanceRequests",
          "ec2:DescribeSpotInstanceRequests"
        ]
        Resource = "*"
      },

      # --------------------------------------------------------
      # IAM — passar a node role para as instâncias EC2
      # --------------------------------------------------------
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = aws_iam_role.karpenter_node.arn
      },

      # --------------------------------------------------------
      # IAM — ler o Instance Profile dos nodes
      # Necessário para o Karpenter confirmar InstanceProfileReady
      # --------------------------------------------------------
      {
        Effect = "Allow"
        Action = [
          "iam:GetInstanceProfile"
        ]
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${var.project_name}-karpenter-node"
      },

      # --------------------------------------------------------
      # Pricing — calcular custo para escolher melhor spot
      # --------------------------------------------------------
      {
        Effect   = "Allow"
        Action   = ["pricing:GetProducts"]
        Resource = "*"
      },

      # --------------------------------------------------------
      # SSM — buscar AMIs otimizadas para EKS
      # --------------------------------------------------------
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter"]
        Resource = "arn:aws:ssm:*:*:parameter/aws/service/eks/optimized-ami/*"
      },

      # --------------------------------------------------------
      # SQS — fila de interrupção de spot
      # --------------------------------------------------------
      {
        Effect = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage"
        ]
        Resource = aws_sqs_queue.karpenter_interruption.arn
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

# ---- IAM Role para os NODES criados pelo Karpenter ----
resource "aws_iam_role" "karpenter_node" {
  name = "${var.project_name}-karpenter-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.project_name}-karpenter-node" })
}

resource "aws_iam_role_policy_attachment" "karpenter_node_worker" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ecr" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_cni" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ssm" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile — necessário para EC2 assumir a role
resource "aws_iam_instance_profile" "karpenter_node" {
  name = "${var.project_name}-karpenter-node"
  role = aws_iam_role.karpenter_node.name
  tags = var.tags
}

# Access Entry — permite que os nodes do Karpenter entrem no cluster
resource "aws_eks_access_entry" "karpenter_node" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_role.karpenter_node.arn
  type          = "EC2_LINUX"
}