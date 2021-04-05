//variable env {}
//variable basename {}

variable vpc_id {}
variable subnet_id {}
variable ssh_allowed_cidr {}
variable ping_allowed_cidr {}
variable existed_keyname{}
variable instance_name{
  default="terraform-bastion"
}
variable public_key_path {
  default="~/.ssh/id_rsa.pub"
}
variable private_ip {
  default = null
}

variable "images" {
    default = {
        us-east-1 = "ami-0920d16f6f54fba27"
        us-west-2 = "ami-"
        us-west-1 = "ami-"
        eu-west-1 = "ami-"
        eu-central-1 = "ami-"
        ap-southeast-1 = "ami-"
        ap-southeast-2 = "ami-"
        ap-northeast-1 = "ami-05d15f93bb93d841f"
        sa-east-1 = "ami-b52890a8"
    }
}

locals {
  ingress_rules = {
    ssh = {
      protocol  = "tcp",
      from_port = 22,
      to_port   = 22,
      cidr      = var.ssh_allowed_cidr
    },
    ping = {
      protocol  = "icmp",
      from_port = 8,
      to_port   = 0,
      cidr      = var.ping_allowed_cidr
    }
  }
}

resource "aws_security_group" ec2 {
  name        = "ec2-sg"
  description = "ec2-sg"
  vpc_id      = var.vpc_id
}

resource aws_security_group_rule egress {
  type              = "egress"
  security_group_id = aws_security_group.ec2.id
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule ingress {
  for_each          = local.ingress_rules
  type              = "ingress"
  security_group_id = aws_security_group.ec2.id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  cidr_blocks       = each.value.cidr
}

/*
resource aws_key_pair bastion_keypair {
  key_name   = "keypair_made_by_terraform_ec2tf"
  public_key = file(var.public_key_path)
}
*/

data aws_subnet subnet {
  id = var.subnet_id
}

resource aws_instance ec2 {
  ami                         = var.images.ap-northeast-1
  instance_type               = "t2.micro"
  availability_zone           = data.aws_subnet.subnet.availability_zone
  monitoring                  = false
  associate_public_ip_address = false // because it's moved to private subnet
  //key_name                    = aws_key_pair.bastion_keypair.key_name
  key_name                    = var.existed_keyname
  tags = {
    Name = var.instance_name
  }
  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = var.subnet_id
  private_ip             = var.private_ip
  iam_instance_profile = "AmazonSSMRoleForInstancesQuickSetup"
}
