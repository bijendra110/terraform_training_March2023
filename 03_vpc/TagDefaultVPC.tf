resource "aws_ec2_tag" "defaultRouteTable" {
  resource_id = aws_vpc.aws_vpc.default_route_table_id
  key         = "Name"
  value       = var.name
}
resource "aws_ec2_tag" "defaultNetworkACL" {
  resource_id = aws_vpc.aws_vpc.default_network_acl_id
  key         = "Name"
  value       = var.name
}
resource "aws_ec2_tag" "defaultSecurityGroup" {
  resource_id = aws_vpc.aws_vpc.default_security_group_id
  key         = "Name"
  value       = var.name
}