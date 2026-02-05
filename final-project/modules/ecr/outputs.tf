output "repository_url" {
  description = "URL репозиторію ECR"
  value       = aws_ecr_repository.main.repository_url
}

output "repository_name" {
  description = "Ім'я репозиторію ECR"
  value       = aws_ecr_repository.main.name
}

output "registry_id" {
  description = "AWS акаунт ID"
  value       = aws_ecr_repository.main.registry_id
}