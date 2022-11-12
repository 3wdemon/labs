provider "aws" {
  region = "us-west-2"
  profile = "sergeykudelin-dev"
}

locals {
  user_data = <<EOF
#!/bin/bash
echo "Hello Terraform!"
EOF
}

data "aws_route53_zone" "selected" {
  name = "sergeykudelin.pp.ua."
}

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


module "sg_elk" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "elk"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules        = ["all-all"]
}

resource "aws_eip" "this" {
  vpc      = true
  instance = module.ec2_elk.id[0]
}

resource "aws_kms_key" "this" {
}

resource "aws_network_interface" "this" {
  count = 1

  subnet_id = tolist(data.aws_subnet_ids.all.ids)[count.index]
}

module "ec2_elk" {
  source = "terraform-aws-modules/ec2-instance/aws"

  instance_count = 1

  name                        = "elk"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.xlarge"
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.sg_elk.security_group_id]
  associate_public_ip_address = true
  key_name                    = "aws_hillel"

  user_data_base64 = base64encode(local.user_data)

  enable_volume_tags = false
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 30
      tags = {
        Name = "my-root-block"
      }
    },
  ]

  tags = {
    "Env"     = "Develop"
    "Purpose" = "elk"
    "Docker" = "true"
  }
}

resource "aws_route53_record" "elk" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "elk.sergeykudelin.pp.ua"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.this.public_ip]
}