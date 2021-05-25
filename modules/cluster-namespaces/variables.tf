variable "cluster_name" {
  description = "The id of the EKS cluster"
}
variable "namespaces" {
  description = "The k8s namespaces to create on the cluster"
  default     = []
}
