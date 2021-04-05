

data "aws_availability_zones" "available" {
  state = "available"
}

module create-vpc-a {
  source = "./module/vpc"
  production-vpc = {
    name = "testDMZ_VPC_A"
    cidr = "100.64.0.0/20"
    public_subnets = {
      vpcA_subnet1_pub = {
        availability_zone = data.aws_availability_zones.available.names[0]
        cidr = "100.64.1.0/24"
        name_eip_nat = "testDMZ_vpc_A_natgw-1" 
        name_natgw = "testDMZ_vpc_A_natgw-1" 
      }
      vpcA_subnet2_pub = {
        availability_zone = data.aws_availability_zones.available.names[1]
        cidr = "100.64.2.0/24"
        name_eip_nat = "testDMZ_vpc_A_natgw-2" 
        name_natgw = "testDMZ_vpc_A_natgw-2" 
      }
    }
    private_subnets = {
      vpcA_subnet3_prv = {
        availability_zone = data.aws_availability_zones.available.names[0]
        cidr = "100.64.3.0/24"
      }
      vpcA_subnet4_prv = {
        availability_zone = data.aws_availability_zones.available.names[1]
        cidr = "100.64.4.0/24"
      }
    }
  }
}

module create-vpc-b {
  source = "./module/vpc_private"
  production-vpc-private = {
    name = "testDMZ_VPC_B"
    cidr = "100.64.16.0/20"

    private_subnets = {
      vpcB_subnet3_prv = {
        availability_zone = data.aws_availability_zones.available.names[0]
        cidr = "100.64.19.0/24"
      }

    }
  }
}
