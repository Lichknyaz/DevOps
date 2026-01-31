output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}


output "eks_cluster_ca_data" {
  description = "EKS cluster CA data (base64)"
  value       = module.eks.cluster_ca_data
}

output "eks_node_group_name" {
  description = "EKS node group name"
  value       = module.eks.node_group_name
}

output "kubeconfig_command" {
  description = "Command to configure kubectl for the cluster"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region eu-west-1"
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.ecr.repository_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "ecr_registry_id" {
  description = "ECR registry ID"
  value       = module.ecr.registry_id
}

output "ecr_login_command" {
  description = "Command to authenticate Docker to ECR"
  value       = "aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin ${module.ecr.registry_id}.dkr.ecr.eu-west-1.amazonaws.com"
}


output "jenkins_release" {
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  value = module.jenkins.jenkins_namespace
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.node_role_arn
}
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider_url
}
