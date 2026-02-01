# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-bucket-lesson-db-lichknyaz"# Назва S3-бакета
#     key            = "lesson-db/terraform.tfstate"   # Шлях до файлу стейту
#     region         = "eu-west-1"                    # Регіон AWS
#     dynamodb_table = "terraform-locks"              # Назва таблиці DynamoDB
#     encrypt        = true                           # Шифрування файлу стейту
#   }
# }

