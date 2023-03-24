resource "aws_eip" "nameGatewayEip" {
  tags = local.tags
}
resource "aws_nat_gateway" "natgatway" {
  allocation_id = aws_eip.nameGatewayEip.id
  subnet_id     = aws_subnet.public[0].id
  tags          = local.tags
}