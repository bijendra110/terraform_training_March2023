output "vpc_id" {
  value = data.aws_vpc.default.id
}
output "subnet_ids" {
  value = data.aws_subnets.default.ids
}
output "db_subnet_group_id" {
  value = aws_db_subnet_group.subnetGroup.id
}

output "secret_id" {
  value = aws_secretsmanager_secret.dbPassword.id
}
output "db_url" {
  value = aws_db_instance.postgres.address
}