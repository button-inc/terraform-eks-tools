variable "cluster_name" {
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

variable "create" {
  description = "Whether to create External DNS"
  type        = bool
  default     = true
}

# see https://github.com/kubernetes-sigs/external-dns/releases/tag/v0.8.0
variable "tool_version" {
  description = "The version of the External DNS"
  default     = "0.8.0"
}
