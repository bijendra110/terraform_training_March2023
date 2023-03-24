resource "aws_route" "netgatewayroute" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private.id
  gateway_id             = aws_nat_gateway.natgatway.id
}