resource "aws_route" "internetroute" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_vpc.aws_vpc.default_route_table_id
  gateway_id             = aws_internet_gateway.internet_gateway.id
}