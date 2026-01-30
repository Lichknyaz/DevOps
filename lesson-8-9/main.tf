# Підключаємо модуль для S3 та DynamoDB
module "s3_backend" {
  source = "./modules/s3_backend"                # Шлях до модуля
  bucket_name = "terraform-state-bucket-lesson-7-lichknyaz"  # Ім'я S3-бакета
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
  ecr_name    = "lesson-7-django-ecr"
  scan_on_push = true
}

# EKS cluster in the existing VPC
module "eks" {
  source                   = "./modules/eks"
  cluster_name             = "lesson-7-eks"
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
