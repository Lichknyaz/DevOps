variable "name" {
  type        = string
  description = "Helm release name."
  default     = "kube-prometheus-stack"
}

variable "namespace" {
  type        = string
  description = "Namespace for monitoring stack."
  default     = "monitoring"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version for kube-prometheus-stack."
  default     = "58.6.0"
}
