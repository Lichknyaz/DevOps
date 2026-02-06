output "grafana_service" {
  value       = "${var.name}-grafana"
  description = "Grafana service name."
}

output "namespace" {
  value       = var.namespace
  description = "Monitoring namespace."
}
