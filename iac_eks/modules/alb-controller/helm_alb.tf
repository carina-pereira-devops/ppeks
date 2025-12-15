resource "helm_release" "eks_helm_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.7"
  namespace  = "kube-system"

    values = [yamlencode({
    clusterName = var.cluster_name
    serviceAccount = {
      create = false
      name   = "aws-load-balancer-controller"
    }
    vpcId = var.vpc_id
  })]
}
