# Terraform

## Оформление 

- Создаем новую ветку в репозитории с именем hw-19_terraform

- Создадим каталог с именем terraform в корне нашего репозитория

## Создадим файл main.tf со следующим кодом

### Variables

```
variable "aws_region" {
  default = "us-west-2"
}

variable "cidr" {
  default = "10.10.0.0/16"
}

variable "cidr_public" {
  default = "10.10.10.0/24"
}

variable "cidr_private" {
  default = "10.10.20.0/24"
}

variable "tags" {
  type = map(any)
  default = {
    Team        = "hillel devops"
    Project     = "vpc"
    Environment = "dev"
  }
}
```

### VPC

```
resource "aws_vpc" "default_vpc" {
  cidr_block = var.cidr
  tags       = var.tags
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = var.cidr_public
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.default_vpc.id
  cidr_block = var.cidr_private

}
```

### Create Internet Gateway

```
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default_vpc.id
}

resource "aws_eip" "ip_pub" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.ip_pub.id
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_eip.ip_pub]
}
```

### Route Table for Public Network

```
resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.default_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "link_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt_public.id
}
```

### Route Table for Private Network

```
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.default_vpc.id
}

resource "aws_route" "route_private" {
  route_table_id         = aws_route_table.rt_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default.id
}

resource "aws_route_table_association" "link_private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.rt_private.id
}
```

### Create security groups

```
resource "aws_security_group" "sg_public" {
  vpc_id      = aws_vpc.default_vpc.id
  description = "Allow SSH inbound traffic"
  name        = "public"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_private" {
  vpc_id      = aws_vpc.default_vpc.id
  description = "Allow inbound traffic from public subnet"
}

resource "aws_security_group_rule" "rule_all" {
  security_group_id = aws_security_group.sg_private.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_public.id
}
```

## Create provider

```
provider "aws" {
  region = var.aws_region
}
```

## Результатом домашнего задания будет

- Созданный Pull Request из ветки hw-19_terraform в основную ветку main (или в другую определенную основной в настройках репозитория)
- Преподователь должен иметь возможность создать инфраструктуру на базе ваших файлов с использованием terraform

## В качестве НЕОБЯЗАТЕЛЬНОГО дополнительного задания
1. Расположите код на разным файлам, согласно лучшим практикам
- https://www.terraform-best-practices.com/code-structure
- https://www.terraform-best-practices.com/naming
2. Можете описать какие ограничения или проблемы Вы видите в коде или что бы улучшили
