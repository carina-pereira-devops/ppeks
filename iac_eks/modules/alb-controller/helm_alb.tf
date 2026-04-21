resource "helm_release" "eks_helm_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.7"
  namespace  = "kube-system"

  # Aguarda o pod estar Running antes de continuar o terraform
  wait    = true
  timeout = 600 # 10 min — nodes do MGN podem demorar para estar prontos

  values = [yamlencode({
    clusterName = var.cluster_name

    serviceAccount = {
      create = false
      name   = "aws-load-balancer-controller"
    }

    vpcId = var.vpc_id

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
      # Anti-affinity: distribui as 2 réplicas em nodes diferentes
      podAntiAffinity = {
        preferredDuringSchedulingIgnoredDuringExecution = [
          {
            weight = 100
            podAffinityTerm = {
              labelSelector = {
                matchLabels = {
                  "app.kubernetes.io/name" = "aws-load-balancer-controller"
                }
              }
              topologyKey = "kubernetes.io/hostname"
            }
          }
        ]
      }
    }
  })]
}
