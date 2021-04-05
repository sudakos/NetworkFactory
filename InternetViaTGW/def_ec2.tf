
locals {
  no_restricted_ip = ["0.0.0.0/0"]
}

module ec2-in-A {
  source = "./module/ec2"

  //env      = var.env
  //basename = "terraform"

  vpc_id            = module.create-vpc-a.vpc_id
  //subnet_id         = module.create-vpc-a.public_subnet_id
  subnet_id         = module.create-vpc-a.private_subnet_id
  //ping_allowed_cidr = module.create-vpc-b.cidr
  ping_allowed_cidr = local.no_restricted_ip
  ssh_allowed_cidr  = [module.create-vpc-a.cidr, module.create-vpc-b.cidr]
  //public_key_path   = var.pubkey
  existed_keyname = var.existed_keyname
  //private_ip        = "100.64.3.5"
  instance_name = "terraform-bastion-vpcA"
}


module ec2-in-B {
  source = "./module/ec2"
  vpc_id            = module.create-vpc-b.vpc_id
  //subnet_id         = module.create-vpc-b.public_subnet_id
  subnet_id         = module.create-vpc-b.private_subnet_id
  //ping_allowed_cidr = module.create-vpc-a.cidr
  ping_allowed_cidr = local.no_restricted_ip
  ssh_allowed_cidr  = [module.create-vpc-a.cidr, module.create-vpc-b.cidr]
  existed_keyname = var.existed_keyname
  instance_name = "terraform-bastion-vpcB"
}
