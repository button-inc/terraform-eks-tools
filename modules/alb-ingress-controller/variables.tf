variable "cluster_id" {
  description = "The id of the EKS cluster"
}

variable "vpc_id" {
  description = "The VPC id of the EKS cluster"
  default     = ""
}

variable "region" {
  description = "The region of the EKS cluster"
  default     = "ca-central-1"
}

variable "controller_verion" {
  description = "The verion of the ALB ingress controller"
  default     = "v1.1.7"
}

variable "create" {
  description = "Whether to create ALB ingress controller"
  type        = bool
  default     = true
}
