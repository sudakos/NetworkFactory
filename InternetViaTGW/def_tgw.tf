
resource aws_ec2_transit_gateway tgw_example {
  vpn_ecmp_support                = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "disable"
}

resource aws_ec2_transit_gateway_route_table tgw_route_example {
  transit_gateway_id = aws_ec2_transit_gateway.tgw_example.id
}

module A-attachment {
  source = "./module/tgw"

  vpc_id                         = module.create-vpc-a.vpc_id
  subnet_ids                     = [module.create-vpc-a.private_subnets[0].id, module.create-vpc-a.private_subnets[1].id,]
  route_table_ids                = [module.create-vpc-a.private_route_tables[0].id, module.create-vpc-a.private_route_tables[1].id,module.create-vpc-a.public_route_table_id]
  transit_gateway_id             = aws_ec2_transit_gateway.tgw_example.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_example.id
  destination_vpc_cidr           = module.create-vpc-b.cidr
}

module B-attachment {
  source = "./module/tgw"

  vpc_id                         = module.create-vpc-b.vpc_id
  subnet_ids                     = [module.create-vpc-b.private_subnet_id ]
  route_table_ids                = [module.create-vpc-b.private_route_table_id]
  transit_gateway_id             = aws_ec2_transit_gateway.tgw_example.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_example.id
  destination_vpc_cidr           = module.create-vpc-a.cidr
}

module Routing-GW {
  source = "./module/routing"

  source_route_table_ids         = [module.create-vpc-b.private_route_table_id]
  gw_attachment_id               = module.A-attachment.attachment_id
  transit_gateway_id             = aws_ec2_transit_gateway.tgw_example.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_example.id
}
