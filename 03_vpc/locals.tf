locals {
  tags = {
    Name = var.name
  }
  count = length(data.aws_availability_zones.azs.names)
  cidr  = split(".", var.cidr_block)
}