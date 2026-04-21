# ============================================================
# NodePool + EC2NodeClass — Nodes de WORKLOAD (spot only)
# Tudo que não é sistema (aplicações + observabilidade) vai aqui
# ============================================================

resource "kubernetes_manifest" "karpenter_ec2_node_class" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "workload"
    }
    spec = {
      # AMI otimizada para EKS — atualiza automaticamente com o cluster
      amiSelectorTerms = [
        {
          alias = "al2023@latest" # Amazon Linux 2023 — recomendado para EKS 1.35+
        }
      ]

      # Role que os nodes vão assumir (criada no iam.tf)
      role = aws_iam_role.karpenter_node.name

      # Apenas subnets PRIVADAS (seus nodes nunca ficam em subnet pública)
      subnetSelectorTerms = [
        { id = var.subnet_private_1a },
        { id = var.subnet_private_1b }
      ]

      # Security Group do cluster (mesmo dos nodes do MGN)
      securityGroupSelectorTerms = [
        {
          tags = {
            "aws:eks:cluster-name" = var.cluster_name
          }
        }
      ]

      # Tags que serão aplicadas nas instâncias EC2 criadas
      tags = merge(var.tags, {
        "karpenter.sh/discovery" = var.cluster_name
        "NodeType"               = "workload"
      })

      # Bloqueia acesso público ao metadata da instância — segurança
      metadataOptions = {
        httpEndpoint            = "enabled"
        httpProtocolIPv6        = "disabled"
        httpPutResponseHopLimit = 1 # Impede que pods acessem o IMDS diretamente
        httpTokens              = "required" # Força IMDSv2
      }
    }
  }

  depends_on = [helm_release.karpenter]
}

resource "kubernetes_manifest" "karpenter_node_pool" {
  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "workload"
    }
    spec = {
      template = {
        metadata = {
          labels = {
            "node-type" = "workload" # Label para afinidade de pods
          }
        }
        spec = {
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "workload"
          }

          # Apenas SPOT — economiza créditos AWS
          requirements = [
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = ["spot"]
            },
            {
              # Famílias de instâncias: boa relação custo/benefício para lab
              # t3/t3a: baratas, boas para cargas variáveis (aplicações)
              # m5/m5a: mais estáveis para observabilidade (Prometheus, Grafana)
              key      = "node.kubernetes.io/instance-type"
              operator = "In"
              values = [
                "t3.small",
                "t3.medium",
                "t3.large",
                "t3a.small",
                "t3a.medium",
                "t3a.large",
                "m5.large",
                "m5a.large"
              ]
            },
            {
              # Apenas as AZs onde suas subnets privadas existem
              key      = "topology.kubernetes.io/zone"
              operator = "In"
              values   = ["us-east-1a", "us-east-1b"]
            },
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = ["amd64"]
            },
            {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = ["linux"]
            }
          ]

          # Os nodes do workload NÃO têm o taint de sistema
          # Então qualquer pod sem tolerations vem aqui automaticamente
        }
      }

      # Limites do NodePool — evita surpresas de custo
      limits = {
        cpu    = "8"  # Máximo 8 vCPUs simultâneos no pool
        memory = "16Gi"
      }

      # Consolidação: remove nodes ociosos para economizar
      disruption = {
        consolidationPolicy = "WhenEmptyOrUnderutilized"
        consolidateAfter    = "30s"

        # Janela de consolidação: evita interromper durante horário de trabalho
        # Ajuste conforme sua necessidade
        budgets = [
          {
            # Permite remover no máximo 20% dos nodes de uma vez
            nodes = "20%"
          }
        ]
      }
    }
  }

  depends_on = [kubernetes_manifest.karpenter_ec2_node_class]
}
