resource "aws_vpc" "aws_vpc" {
  instance_tenancy     = "default"
  cidr_block           = var.cidr_block
  tags                 = local.tags
  enable_dns_hostnames = true
}