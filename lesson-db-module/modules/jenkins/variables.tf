variable "cluster_name" {
  description = "Назва Kubernetes кластера"
  type        = string
}
variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for IRSA"
  type        = string
}
