data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


resource "aws_db_subnet_group" "subnetGroup" {
  name        = var.name
  description = "subnet group managed by Terraform for ${var.name}"
  tags = {
    Name = var.name
  }
  subnet_ids = data.aws_subnets.default.ids
}

data "aws_security_group" "security_group" {
  filter {
    name   = "tag:Name"
    values = ["kul"]
  }
}

resource "aws_db_instance" "postgres" {
  engine                  = "postgres"
  engine_version          = "14.6"
  multi_az                = false
  identifier              = var.name
  username                = "postgres"
  password                = random_password.dbPassword.result
  instance_class          = "db.t3.micro"
  storage_type            = "gp2"
  allocated_storage       = "5"
  max_allocated_storage   = "20"
  db_subnet_group_name    = aws_db_subnet_group.subnetGroup.name
  publicly_accessible     = true
  vpc_security_group_ids  = [data.aws_security_group.security_group.id]
  db_name                 = var.name
  skip_final_snapshot     = true
  maintenance_window      = "Sun:00:00-Sun:03:00"
  backup_window           = "03:00-05:00"
  backup_retention_period = 0
  apply_immediately       = true
}
