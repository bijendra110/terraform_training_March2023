resource "aws_route_table_association" "privateSubnets" {
  count = local.count
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private[count.index].id
}
resource "aws_route_table_association" "publicSubnets" {
  count = local.count
  route_table_id = aws_vpc.aws_vpc.default_route_table_id
  subnet_id = aws_subnet.public[count.index].id  
}