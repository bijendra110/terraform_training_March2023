resource "aws_route_table" "private" {
  vpc_id = aws_vpc.aws_vpc.id
  tags   = local.tags
}