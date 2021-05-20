data "aws_eks_cluster" "this" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_id
}

data "aws_caller_identity" "this" {}

data "aws_vpc" "this" {
  id = var.vpc_id != "" ? var.vpc_id : data.aws_eks_cluster.this.vpc_config[0].vpc_id
}
