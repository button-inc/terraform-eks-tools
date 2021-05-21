module "alb_ingress_controller" {
  source = "./modules/alb-ingress-controller"

  create       = var.create_alb_ingress_controller
  cluster_name = var.cluster_name
  vpc_id       = var.vpc_id
  region       = var.region
  tool_version = var.alb_ingress_controller_version
}

module "external_dns" {
  source = "./modules/external-dns"

  create       = var.create_external_dns
  cluster_name = var.cluster_name
  vpc_id       = var.vpc_id
  region       = var.region
  tool_version = var.external_dns_version
}
