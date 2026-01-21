variable "ecr_name" {
  description = "Ім'я ECR репозиторію"
  type        = string
}

variable "scan_on_push" {
  description = "Автоматично сканувати образи при push"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Дозволити перезапис тегів образів"
  type        = string
  default     = "MUTABLE"
}