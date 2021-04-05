

// modules/tgw/vpc-attachment.tf

variable source_route_table_ids {}
variable gw_attachment_id {}
variable transit_gateway_id {}
variable transit_gateway_route_table_id {}

locals {
  default_route = "0.0.0.0/0"
}

resource aws_route to_gw_vpc {
  count = length(var.source_route_table_ids)
  route_table_id         = var.source_route_table_ids[count.index]
  transit_gateway_id     = var.transit_gateway_id
  destination_cidr_block = local.default_route
}

resource aws_ec2_transit_gateway_route default_route {
  destination_cidr_block         = local.default_route
  transit_gateway_attachment_id  = var.gw_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}
