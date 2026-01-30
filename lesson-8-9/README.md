# lesson-7

## Overview

Terraform configuration for AWS infrastructure (S3 backend, VPC, ECR, EKS) and a Helm chart for deploying a Django app.

## Project Structure

```
lesson-7/
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
│   ├── eks/                 # Модуль для Kubernetes кластера
│   │   ├── eks.tf           # Створення кластера
│   │   ├── variables.tf     # Змінні для EKS
│   │   └── outputs.tf       # Виведення інформації про кластер
│
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
