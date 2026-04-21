# ============================================================
# Helm — Deploy do Karpenter no cluster
# Roda no MGN (nodes de sistema) — sem toleration de workload
# ============================================================

resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.3.3" # Compatível com EKS 1.35
  namespace  = "kube-system"

  # Aguarda o pod estar Running antes de continuar o terraform
  wait    = true
  timeout = 300

  values = [
    yamlencode({
      # Service Account com IRSA
      serviceAccount = {
        create = true
        name   = "karpenter"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_controller.arn
        }
      }

      settings = {
        clusterName       = var.cluster_name
        clusterEndpoint   = var.cluster_endpoint
        interruptionQueue = aws_sqs_queue.karpenter_interruption.name
      }

      tolerations = [{
        key      = "CriticalAddonsOnly"
        operator = "Exists" # ← Exists, não Equal — é como o EKS usa
      }]

      affinity = {
        nodeAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = {
            nodeSelectorTerms = [
              {
                matchExpressions = [
                  {
                    key      = "CriticalAddonsOnly"
                    operator = "Exists"
                  }
                ]
              }
            ]
          }
        }
        # Anti-affinity: distribui os 2 pods do Karpenter em AZs diferentes
        podAntiAffinity = {
          preferredDuringSchedulingIgnoredDuringExecution = [
            {
              weight = 100
              podAffinityTerm = {
                labelSelector = {
                  matchLabels = {
                    "app.kubernetes.io/name" = "karpenter"
                  }
                }
                topologyKey = "kubernetes.io/hostname"
              }
            }
          ]
        }
      }

      # 2 réplicas para HA (uma em cada node do MGN)
      replicas = 2

      controller = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      logLevel = "info"
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.karpenter_controller,
    aws_eks_access_entry.karpenter_node
  ]
}
