variable "production-vpc-private" {
  default = {
    name = "production-vpc"
    cidr = "10.0.0.0/16"
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

resource "aws_vpc" "a_vpc-private" {
  cidr_block = var.production-vpc-private.cidr
  tags = {
    Name = var.production-vpc-private.name
  }
}

resource "aws_subnet" "private_subnets-private" {
  count = length(var.production-vpc-private.private_subnets)
  cidr_block = values(var.production-vpc-private.private_subnets)[count.index].cidr
  availability_zone = values(var.production-vpc-private.private_subnets)[count.index].availability_zone
  tags = {
    Name = keys(var.production-vpc-private.private_subnets)[count.index]
  }
  vpc_id = aws_vpc.a_vpc-private.id
}

resource "aws_route_table" "private-routes-private" {
  // count = length(var.production-vpc-private.public_subnets)
  count = 1
  vpc_id = aws_vpc.a_vpc-private.id
  //route {
  //  cidr_block = "0.0.0.0/0"
  //  gateway_id = aws_nat_gateway.nats[count.index].id
  //}
}

resource "aws_route_table_association" "private_route_association-private" {
  // count = length(var.production-vpc-private.public_subnets)
  count = 1
  subnet_id = aws_subnet.private_subnets-private[count.index].id
  route_table_id = aws_route_table.private-routes-private[count.index].id
}

output vpc_id {
  value = aws_vpc.a_vpc-private.id
}
output cidr {
  value = aws_vpc.a_vpc-private.cidr_block
}

output private_subnet_id {
  value = aws_subnet.private_subnets-private[0].id
}
output private_route_table_id {
  value = aws_route_table.private-routes-private[0].id
}
