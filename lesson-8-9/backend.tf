terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-lesson-8-9-lichknyaz"# Назва S3-бакета
    key            = "lesson-8-9/terraform.tfstate"   # Шлях до файлу стейту
    region         = "eu-west-1"                    # Регіон AWS
    dynamodb_table = "terraform-locks"              # Назва таблиці DynamoDB
    encrypt        = true                           # Шифрування файлу стейту
  }
}

