# ── Regra existente — mantida ────────────────────────────────────────────────
resource "aws_security_group_rule" "eks_cluster_sg_rule" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

# ── Istio: webhook de injeção do sidecar ─────────────────────────────────────
# O API server chama o istiod na porta 15017 para cada Pod criado em namespace
# com istio-injection=enabled. Se bloqueada, o Helm trava com
# "context deadline exceeded" ao instalar o istiod.
resource "aws_security_group_rule" "eks_istio_webhook" {
  type              = "ingress"
  description       = "Istio sidecar injection webhook - control plane to nodes"
  from_port         = 15017
  to_port           = 15017
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

# ── Istio: comunicação xDS (istiod → Envoy sidecars) ─────────────────────────
# O istiod distribui configuração de roteamento para os proxies Envoy
# via gRPC na porta 15012. Sem essa regra, os sidecars sobem mas não
# recebem configuração — tráfego da malha não funciona.
resource "aws_security_group_rule" "eks_istio_xds" {
  type              = "ingress"
  description       = "Istio xDS - istiod to Envoy sidecars"
  from_port         = 15012
  to_port           = 15012
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}