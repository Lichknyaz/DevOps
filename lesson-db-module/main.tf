# Підключаємо модуль для S3 та DynamoDB
module "s3_backend" {
  source = "./modules/s3_backend"                # Шлях до модуля
  bucket_name = "terraform-state-bucket-lesson-8-9-lichknyaz"  # Ім'я S3-бакета
  table_name  = "terraform-locks"                # Ім'я DynamoDB
}

# Підключаємо модуль для VPC
module "vpc" {
  source              = "./modules/vpc"           # Шлях до модуля VPC
  vpc_cidr_block      = "10.0.0.0/16"             # CIDR блок для VPC
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]        # Публічні підмережі
  private_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]         # Приватні підмережі
  availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]            # Зони доступності
  vpc_name            = "vpc_terraform"              # Ім'я VPC
}

# Підключаємо модуль ECR
module "ecr" {
  source      = "./modules/ecr"
  ecr_name    = "lesson-8-9-django-ecr"
  scan_on_push = true
}

# EKS cluster in the existing VPC
module "eks" {
  source                   = "./modules/eks"
  cluster_name             = "lesson-8-9-eks"
  cluster_version          = "1.29"
  subnet_ids               = module.vpc.private_subnets
  node_subnet_ids          = module.vpc.private_subnets
  node_group_name          = "default"
  node_instance_types      = ["t3.medium"]
  node_min_size            = 1
  node_max_size            = 3
  node_desired_size        = 2
  endpoint_public_access   = true
  endpoint_private_access  = true
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "jenkins" {
  source       = "./modules/jenkins"
  cluster_name = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  providers = {
    helm       = helm
    kubernetes = kubernetes
    aws        = aws
  }
}

module "argo_cd" {
  source       = "./modules/argo_cd"
  namespace    = "argocd"
  chart_version = "5.46.4"

  providers = {
    helm = helm
  }
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
