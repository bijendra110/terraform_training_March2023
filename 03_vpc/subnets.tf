resource "aws_subnet" "private" {
  count                   = local.count
  vpc_id                  = aws_vpc.aws_vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  cidr_block              = "${local.cidr[0]}.${local.cidr[1]}.${var.private_subnet_start + count.index}.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name}_private_${var.private_subnet_start + count.index}"
    Type = "private"
  }
}
resource "aws_subnet" "public" {
  count                   = local.count
  vpc_id                  = aws_vpc.aws_vpc.id
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  cidr_block              = "${local.cidr[0]}.${local.cidr[1]}.${var.public_subnet_start + count.index}.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}_public_${var.public_subnet_start + count.index}"
    Type = "public"
  }
}