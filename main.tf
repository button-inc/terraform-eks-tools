module "alb_ingress_controller" {
  source = "./modules/alb-ingress-controller"

  create            = var.create_alb_ingress_controller
  cluster_id        = var.cluster_id
  vpc_id            = var.vpc_id
  region            = var.region
  controller_verion = var.alb_ingress_controller_verion
}

module "external_dns" {
  source = "./modules/external-dns"

  create     = var.create_external_dns
  cluster_id = var.cluster_id
  vpc_id     = var.vpc_id
  region     = var.region
}
