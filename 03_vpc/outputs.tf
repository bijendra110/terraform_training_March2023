output "vpc_id" {
  value = aws_vpc.aws_vpc.id
}
output "availability_zones" {
  value = data.aws_availability_zones.azs.names
}
output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}
output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}