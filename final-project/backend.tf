# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket-final-project-lichknyaz"# Назва S3-бакета
#     key            = "final-project/terraform.tfstate"   # Шлях до файлу стейту
#     region         = "eu-west-1"                    # Регіон AWS
#     dynamodb_table = "terraform-locks"              # Назва таблиці DynamoDB
#     encrypt        = true                           # Шифрування файлу стейту
#   }
# }

