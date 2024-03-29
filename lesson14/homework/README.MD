# Variables

    variable "aws_region" {
    default = "eu-west-2"
    }

    variable "instance_count" {
    default = 1
    }

    variable "instance_type" {
    default = "t2.micro"
    }

    variable "cidr" {
    default = "10.10.0.0/16"
    }

    variable "cidr_pub" {
    default = "10.10.10.0/24"
    }

    variable "cidr_priv" {
    default = "10.10.20.0/24"
    }

    variable "tags" {
    type = map
    default = {
        Team    = "Hillel devops"
        project = "vpc"
    }
    }

# VPC

    resource "aws_vpc" "default_vpc" {
    cidr_block = var.cidr
    tags       = var.tags
    }

    resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.default_vpc.id
    cidr_block              = var.cidr_pub
    map_public_ip_on_launch = true
    }

    resource "aws_subnet" "private" {
    vpc_id     = aws_vpc.default_vpc.id
    cidr_block = var.cidr_priv

    }

# GATEWAY

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

# ROUTES

## PUBLIC

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

## PRIVATE

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

# ADD SECURITY GROUPS

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

# PROVIDER

    provider "aws" {
    profile = "default"
    region  = var.aws_region
    }

# AMI

    data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["*ubuntu-bionic-18.04-amd64*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
    }