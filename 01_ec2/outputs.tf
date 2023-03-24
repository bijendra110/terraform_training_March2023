output "vpc_id" {
  value = data.aws_vpc.default.id
}
output "ami_id" {
  value = data.aws_ami.ubuntu.id
}

output "security_group_id" {
  value = aws_security_group.ubuntuEC2.id
}
output "public_ip" {
  value = aws_instance.ubuntuEC2.public_ip
}
output "httpd_status_code" {
  value = "Status code for http://${aws_instance.ubuntuEC2.public_ip}:80: ${data.http.httpd.status_code}"
}