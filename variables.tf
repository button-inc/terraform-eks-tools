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

variable "alb_ingress_controller_verion" {
  description = "The verion of the ALB ingress controller"
  default     = "v1.1.7"
}
