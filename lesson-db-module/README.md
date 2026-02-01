# lesson-db

## Overview

Terraform configuration for AWS infrastructure (S3 backend, VPC, ECR, EKS) and a Helm chart for deploying a Django app.

## Project Structure

```

lesson-db/
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
aws eks update-kubeconfig --name lesson-db-eks --region eu-west-1
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

## How to apply Terraform

```bash
terraform init
terraform plan
terraform apply
```

## How to check Jenkins job

1. Open Jenkins UI (LoadBalancer service in `jenkins` namespace).
2. Run **seed-job** once to (re)create the pipeline job.
3. Run **goit-django-docker** and verify in console log:
   - image build
   - push to ECR
   - commit + push to `example-repo`

## How to see result in Argo CD

1. Open Argo CD UI (service `argocd-server` in `argocd` namespace).
2. Find the `example-app` Application.
3. Verify it shows **Synced** and the latest Git revision after Jenkins push.
