resource "aws_eip" "stage" {
  vpc      = true
  instance = module.ec2_stage.id[0]
}

resource "aws_kms_key" "stage" {
}

resource "aws_network_interface" "stage" {
  count = 1

  subnet_id = tolist(data.aws_subnet_ids.all.ids)[count.index]
}

module "ec2_stage" {
  source = "terraform-aws-modules/ec2-instance/aws"

  instance_count = 1

  name                        = "stage"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids      = [module.sg_jenkins.security_group_id]
  associate_public_ip_address = true
  key_name                    = "jenkins"

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
    "Env"     = "stage"
    "Purpose" = "server"
    "Docker" = "true"
  }
}

resource "aws_route53_record" "stage" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "stage.sergeykudelin.pp.ua"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.stage.public_ip]
}
