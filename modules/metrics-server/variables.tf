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
  description = "Whether to create Metrics Server"
  type        = bool
  default     = true
}

# see https://github.com/kubernetes-sigs/metrics-server/releases
variable "tool_version" {
  description = "The version of the Metrics Server"
  default     = "0.4.4"
}
