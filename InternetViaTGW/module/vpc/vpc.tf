variable "production-vpc" {
  default = {
    name = "production-vpc"
    cidr = "10.0.0.0/16"
    public_subnets = {
      subnet1 = {
        availability_zone = "ap-northeast-1a"
        cidr = "10.0.0.0/28"
        name_eip_nat = "natgw-1" 
        name_natgw = "natgw-1" 
      }
      subnet2 = {
        availability_zone = "ap-northeast-1c"
        cidr = "10.0.0.16/28"
        name_eip_nat = "natgw-2" 
        name_natgw = "natgw-2" 
      }
    }
    private_subnets = {
      subnet3 = {
        availability_zone = "ap-northeast-1a"
        cidr = "10.0.0.32/28"
      }
      subnet4 = {
        availability_zone = "ap-northeast-1c"
        cidr = "10.0.0.48/28"
      }
    }
  }
}

resource "aws_vpc" "a_vpc" {
  cidr_block = var.production-vpc.cidr
  tags = {
    Name = var.production-vpc.name
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.production-vpc.public_subnets)
  cidr_block = values(var.production-vpc.public_subnets)[count.index].cidr
  availability_zone = values(var.production-vpc.public_subnets)[count.index].availability_zone
  tags = {
    Name = keys(var.production-vpc.public_subnets)[count.index]
  }
  vpc_id = aws_vpc.a_vpc.id
}
resource "aws_subnet" "private_subnets" {
  count = length(var.production-vpc.private_subnets)
  cidr_block = values(var.production-vpc.private_subnets)[count.index].cidr
  availability_zone = values(var.production-vpc.private_subnets)[count.index].availability_zone
  tags = {
    Name = keys(var.production-vpc.private_subnets)[count.index]
  }
  vpc_id = aws_vpc.a_vpc.id
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.a_vpc.id
}

resource "aws_eip" "eips_for_nat" {
  vpc = true
  // count = length(var.production-vpc.public_subnets)
  count = 2

  tags = {
    Name = values(var.production-vpc.public_subnets)[count.index].name_eip_nat
  }
}

resource "aws_nat_gateway" "nats" {
  // count = length(var.production-vpc.public_subnets)
  count = 2

  subnet_id     =  aws_subnet.public_subnets[count.index].id
  allocation_id = aws_eip.eips_for_nat[count.index].id

  tags = {
    Name = values(var.production-vpc.public_subnets)[count.index].name_natgw
  }
}

resource "aws_route_table" "public-route" {
    vpc_id = aws_vpc.a_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table" "private-routes" {
  // count = length(var.production-vpc.public_subnets)
  count = 2
  vpc_id = aws_vpc.a_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nats[count.index].id
  }
}

resource "aws_route_table_association" "puclic_route_association" {
  count = length(var.production-vpc.public_subnets)
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "private_route_association" {
  // count = length(var.production-vpc.public_subnets)
  count = 2
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private-routes[count.index].id
}

output "output_id_of_igw" {
  value = aws_internet_gateway.igw.id
}

output vpc_id {
  value = aws_vpc.a_vpc.id
}
output cidr {
  value = aws_vpc.a_vpc.cidr_block
}

output private_subnet_id {
  value = aws_subnet.private_subnets[0].id
}
output public_subnet_id {
  value = aws_subnet.public_subnets[0].id
}
output private_route_table_id {
  value = aws_route_table.private-routes[0].id
}
output public_route_table_id {
  value = aws_route_table.public-route.id
}

output private_subnets {
  value = aws_subnet.private_subnets
}
output private_route_tables {
  value = aws_route_table.private-routes
}
