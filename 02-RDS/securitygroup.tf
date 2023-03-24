#resource "aws_security_group" "security_group" {
#  name        = var.name
#  description = "security group managed by Terraform for bijendra"
#  vpc_id      = data.aws_vpc.default.id
#  ingress {
#    description      = "postgres"
#    from_port        = 5432
#    to_port          = 5432
#    protocol         = "tcp"
#    cidr_blocks      = ["172.31.0.0/16"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#  egress {
#    from_port        = 0
#    to_port          = 0
#    protocol         = "-1"
#    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#  tags = {
#    Name = var.name
#  }
#}  
