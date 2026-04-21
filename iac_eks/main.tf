# Para inicializar novos módulos necessitamos do terraform init
module "eks_network" {
  source       = "./modules/network"
  cidr_block   = var.cidr_block
  project_name = var.project_name
  tags         = var.tags
}

module "eks_cluster" {
  source           = "./modules/cluster"
  project_name     = var.project_name
  tags             = var.tags
  public_subnet_1a = module.eks_network.subnet_pub_1a
  public_subnet_1b = module.eks_network.subnet_pub_1b
}

module "eks_managed_node_group" {
  source            = "./modules/managed-node-group"
  project_name      = var.project_name
  cluster_name      = module.eks_cluster.cluster_name
  subnet_private_1a = module.eks_network.subnet_priv_1a
  subnet_private_1b = module.eks_network.subnet_priv_1b
  tags              = var.tags
}

module "eks_aws_load_balancer_controller" {
  source       = "./modules/alb-controller"
  project_name = var.project_name
  tags         = var.tags
  oidc         = module.eks_cluster.oidc
  cluster_name = module.eks_cluster.cluster_name
  vpc_id       = module.eks_network.vpc_id

  # Garante que os nodes existam antes de instalar o controller
  depends_on = [module.eks_managed_node_group]
}

module "eks_karpenter" {
  source           = "./modules/karpenter"
  project_name     = var.project_name
  tags             = var.tags
  cluster_name     = module.eks_cluster.cluster_name
  cluster_endpoint = module.eks_cluster.endpoint
  oidc             = module.eks_cluster.oidc
  subnet_private_1a = module.eks_network.subnet_priv_1a
  subnet_private_1b = module.eks_network.subnet_priv_1b

  # Karpenter só pode ser instalado depois que o MGN estiver pronto
  # (precisa de nodes para o pod do controller subir)
  depends_on = [module.eks_managed_node_group]
}