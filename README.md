# final-project

## Overview

Terraform configuration for AWS infrastructure (S3 backend, VPC, ECR, EKS), Helm charts for Django + CI/CD, and an additional `final-project` workspace that includes Jenkins, Argo CD, and a reusable RDS/Aurora module.

## Project Structure

```
final-project/

│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальні виводи ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf
│   ├── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf           # Створення ECR репозиторію
│   │   ├── variables.tf     # Змінні для ECR
│   │   └── outputs.tf       # Виведення URL репозиторію
│   │
│   ├── eks/                      # Модуль для Kubernetes кластера
│   │   ├── eks.tf                # Створення кластера
│   │   ├── aws_ebs_csi_driver.tf # Встановлення плагіну csi drive
│   │   ├── variables.tf     # Змінні для EKS
│   │   └── outputs.tf       # Виведення інформації про кластер
│   │
│   ├── rds/                 # Модуль для RDS
│   │   ├── rds.tf           # Створення RDS бази даних
│   │   ├── aurora.tf        # Створення aurora кластера бази даних
│   │   ├── shared.tf        # Спільні ресурси
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   └── outputs.tf
│   │
│   ├── jenkins/             # Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf       # Helm release для Jenkins
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   ├── providers.tf     # Оголошення провайдерів
│   │   ├── values.yaml      # Конфігурація jenkins
│   │   └── outputs.tf       # Виводи (URL, пароль адміністратора)
│   │
│   └── argo_cd/             # ✅ Новий модуль для Helm-установки Argo CD
│       ├── jenkins.tf       # Helm release для Jenkins
│       ├── variables.tf     # Змінні (версія чарта, namespace, repo URL тощо)
│       ├── providers.tf     # Kubernetes+Helm.  переносимо з модуля jenkins
│       ├── values.yaml      # Кастомна конфігурація Argo CD
│       ├── outputs.tf       # Виводи (hostname, initial admin password)
│		    └──charts/                  # Helm-чарт для створення app'ів
│ 	 	    ├── Chart.yaml
│	  	    ├── values.yaml          # Список applications, repositories
│			    └── templates/
│		        ├── application.yaml
│		        └── repository.yaml
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml     # ConfigMap зі змінними середовища


```

## Prerequisites

- Terraform
- AWS CLI
- Docker
- kubectl
- Helm

## Terraform

```bash
terraform init
terraform plan
terraform apply
```

To destroy:

```bash
terraform destroy
```

## ECR (AWS CLI)

1. Create the repository:

```bash
terraform apply
```

2. Get the repository URL:

```bash
terraform output -raw ecr_repository_url
```

3. Login to ECR:

```bash
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <registry-id>.dkr.ecr.eu-west-1.amazonaws.com
```

4. Build and push the Django image:

```bash
docker build -t django-app .
docker tag django-app:latest <repository-url>:latest
docker push <repository-url>:latest
```

Use Terraform outputs:

```bash
terraform output -raw ecr_registry_id
terraform output -raw ecr_repository_url
```

## Helm

1. Configure kubectl for EKS:

```bash
aws eks update-kubeconfig --name lesson-7-eks --region eu-west-1
```

2. Update Helm values with your ECR image:

```bash
# charts/django-app/values.yaml
# image:
#   repository: <repository-url>
#   tag: latest
```

3. Install or upgrade the release:

```bash
helm upgrade --install django-app charts/django-app
```

4. Check resources:

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```

## final-project notes

### How to apply Terraform

```bash
terraform init
terraform plan
terraform apply
```

### How to check Jenkins job

1. Open Jenkins UI (LoadBalancer service in `jenkins` namespace).
2. Run **seed-job** once to (re)create the pipeline job.
3. Run **goit-django-docker** and verify in console log:
   - image build
   - push to ECR
   - commit + push to `example-repo`

### How to see result in Argo CD

1. Open Argo CD UI (service `argocd-server` in `argocd` namespace).
2. Find the `example-app` Application.
3. Verify it shows **Synced** and the latest Git revision after Jenkins push.

## RDS Module (final-project)

### Example usage

```hcl
module "rds" {
  source = "./modules/rds"

  name                  = "myapp-db"
  use_aurora            = true
  aurora_instance_count = 2

  # Aurora-only
  engine_cluster             = "aurora-postgresql"
  engine_version_cluster     = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  # RDS-only
  engine                     = "postgres"
  engine_version             = "15.3"
  parameter_group_family_rds = "postgres15"

  # Common
  instance_class        = "db.t3.medium"
  allocated_storage     = 20
  db_name               = "myapp"
  username              = "postgres"
  password              = "CHANGE_ME"
  vpc_id                = module.vpc.vpc_id
  subnet_private_ids    = module.vpc.private_subnets
  subnet_public_ids     = module.vpc.public_subnets
  publicly_accessible   = false
  multi_az              = true
  port                  = 5432
  backup_retention_period = 7
  parameters = {
    max_connections = "200"
    log_statement   = "all"
    work_mem        = "4MB"
  }
  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Variables

- `name` (string): Base name for DB resources.
- `use_aurora` (bool): `true` for Aurora cluster, `false` for single RDS instance.
- `engine` (string): RDS engine (e.g., `postgres`, `mysql`).
- `engine_version` (string): RDS engine version.
- `engine_cluster` (string): Aurora engine (e.g., `aurora-postgresql`, `aurora-mysql`).
- `engine_version_cluster` (string): Aurora engine version.
- `instance_class` (string): Instance class for RDS/Aurora instances.
- `allocated_storage` (number): Storage size (GB) for standard RDS.
- `aurora_instance_count` (number): Total Aurora instances (1 writer + N readers).
- `db_name` (string): Initial database name.
- `username` (string): Master username.
- `password` (string, sensitive): Master password.
- `vpc_id` (string): VPC ID for the security group.
- `subnet_private_ids` (list(string)): Private subnet IDs.
- `subnet_public_ids` (list(string)): Public subnet IDs.
- `publicly_accessible` (bool): Whether the DB is publicly accessible.
- `multi_az` (bool): Multi-AZ for standard RDS.
- `port` (number): DB port (5432 for Postgres, 3306 for MySQL).
- `backup_retention_period` (number): Days to keep backups.
- `parameters` (map(string)): DB parameters (e.g., `max_connections`, `log_statement`, `work_mem`).
- `parameter_group_family_rds` (string): Parameter group family for RDS.
- `parameter_group_family_aurora` (string): Parameter group family for Aurora.
- `tags` (map(string)): Tags for all resources.

### How to change DB type, engine, class

- Switch between Aurora and RDS: set `use_aurora = true` or `false`.
- Change DB engine/version:
  - RDS: set `engine` and `engine_version`.
  - Aurora: set `engine_cluster` and `engine_version_cluster`.
- Change instance size: set `instance_class` (e.g., `db.t3.medium`).
- Change storage (RDS only): set `allocated_storage`.
- Change port: set `port` (Postgres `5432`, MySQL `3306`).
