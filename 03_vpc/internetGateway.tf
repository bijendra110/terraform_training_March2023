resource "aws_internet_gateway" "internet_gateway" {
  tags   = local.tags
  vpc_id = aws_vpc.aws_vpc.id
}