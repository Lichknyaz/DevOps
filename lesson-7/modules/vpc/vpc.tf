# Створюємо основну VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block   # CIDR блок для нашої VPC (наприклад, 10.0.0.0/16)
  enable_dns_support   = true                 # Вмикає підтримку DNS у VPC
  enable_dns_hostnames = true                 # Вмикає можливість використання DNS-імен для ресурсів у VPC

  tags = {
    Name = "${var.vpc_name}-vpc"              # Додаємо тег, який включає ім'я VPC
  }
}

# Створюємо публічні підмережі
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)   # Створюємо кілька підмереж, кількість визначена довжиною списку public_subnets
  vpc_id                  = aws_vpc.main.id              # Прив'язуємо кожну підмережу до VPC, створеної раніше
  cidr_block              = var.public_subnets[count.index] # CIDR-блок для конкретної підмережі зі списку public_subnets
  availability_zone       = var.availability_zones[count.index] # Визначаємо зони доступності для кожної підмережі
  map_public_ip_on_launch = true                         # Автоматично надає публічні IP-адреси інстансам у підмережі

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"  # Тег з нумерацією підмережі
  }
}

# Створюємо приватні підмережі
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)   # Створюємо кілька приватних підмереж, кількість відповідає довжині списку private_subnets
  vpc_id            = aws_vpc.main.id               # Прив'язуємо кожну приватну підмережу до VPC
  cidr_block        = var.private_subnets[count.index] # CIDR-блок для конкретної підмережі зі списку private_subnets
  availability_zone = var.availability_zones[count.index] # Визначаємо зони доступності для підмереж

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"  # Тег для підмережі з нумерацією
  }
}

# Створюємо Internet Gateway для публічних підмереж
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id   # Прив'язуємо Internet Gateway до VPC для виходу в інтернет

  tags = {
    Name = "${var.vpc_name}-igw"   # Тег для ідентифікації Internet Gateway
  }
}

# Створюємо Elastic IP для NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = { Name = "lesson-5-nat-eip" }
  depends_on = [aws_internet_gateway.igw]
}

# Створюємо єдиний NAT Gateway у першій публічній підмережі
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  # Розміщуємо в першій публічній підмережі
  tags = { Name = "lesson-5-nat-gateway" }
  depends_on = [aws_internet_gateway.igw]
}
