variable "cluster_name" {
  description = "The name of the EKS cluster"
}

variable "vpc_id" {
  description = "The VPC id of the EKS cluster"
  default     = ""
}

variable "region" {
  description = "The region of the EKS cluster"
  default     = "ca-central-1"
}

variable "create_alb_ingress_controller" {
  description = "Whether to create ALB ingress controller"
  type        = bool
  default     = true
}

variable "create_external_dns" {
  description = "Whether to create External DNS"
  type        = bool
  default     = true
}

variable "create_metrics_server" {
  description = "Whether to create Metrics server"
  type        = bool
  default     = true
}

variable "alb_ingress_controller_version" {
  description = "The verion of the ALB ingress controller"
  default     = "1.1.7"
}

variable "external_dns_version" {
  description = "The version of the External DNS"
  default     = "0.8.0"
}

variable "metrics_server_version" {
  description = "The version of the Metrics server"
  default     = "0.4.4"
}

variable "cluster_namespaces" {
  description = "The k8s namespaces to create on the cluster"
  default     = []
}
