provider "aws" {
  region = "us-east-2" # OHIO
}

data "aws_ami" "ubuntu" {   # Data block is used to fetch the information about existing resources
  owners = ["554660509057"] # First Filter
  filter {                  # Second Filter
    name   = "tag:Name"
    values = ["ubuntu"]
  }
  most_recent = true # Third Filter
}

variable "name" {
  type        = string
  description = "Enter value to be used with name tag & name arguments. e.g. kul navin harshitha"
}
variable "private_key_path" {
  type        = string
  description = "Enter the path to store private key pem file. e.g c:/users/kulbh/.ssh"
}

resource "aws_instance" "ubuntuEC2" {    # resource block is used to create new resources
  ami           = data.aws_ami.ubuntu.id # Attribute Referenced from Data Source
  instance_type = "t2.micro"
  tags = {
    Name = var.name
  }
  key_name               = aws_key_pair.ubuntuEC2.key_name
  vpc_security_group_ids = [aws_security_group.ubuntuEC2.id]
  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = "16"
    tags = {
      Name = var.name
    }
  }
  #ebs_block_device {
  #  delete_on_termination = true
  #  volume_type           = "gp2"
  # volume_size           = "15"
  #  tags = {
  #    Name = var.name
  #  }
  #  device_name = "/dev/sdf"
  #}
  provisioner "remote-exec" { # use to run defined commands in sequence on the remote server
    connection {              # connection details
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ubuntuEC2.private_key_pem
    }
    inline = [
      "mkdir ~/ansible"
    ]
  }
}

data "aws_vpc" "default" {
  default = true # Fetch the detail about default network available in the current region
}

resource "aws_security_group" "ubuntuEC2" {
  name        = var.name
  description = "security group managed by Terraform for Kul"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.name
  }
}

##########################################################
## blocks for keypair creation
##########################################################
provider "tls" {} # use to generate certificate, keypair
resource "tls_private_key" "ubuntuEC2" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}
resource "aws_key_pair" "ubuntuEC2" {
  key_name   = "${var.name}-keypair"
  public_key = tls_private_key.ubuntuEC2.public_key_openssh
}
##########################################################

##########################################################
## blocks to create pem file from tls_private_key
##########################################################
provider "local" {}
resource "local_file" "pem_file" {
  content  = tls_private_key.ubuntuEC2.private_key_pem
  filename = "${var.private_key_path}/${aws_key_pair.ubuntuEC2.key_name}.pem"
}
##########################################################

##########################################################
## blocks to copy file from local system to remote machine
##########################################################
provider "null" {}
resource "null_resource" "copy_ansible_cfg" {
  triggers = {
    run_always = timestamp()
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.ubuntuEC2.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ubuntuEC2.private_key_pem
    }
    source      = "./ansible.cfg"
    destination = "/home/ubuntu/ansible/ansible.cfg"
  }
}
##########################################################

##########################################################
## blocks to create and copy inventory file
##########################################################
resource "null_resource" "create_ansible_inventory" {
  provisioner "local-exec" {
    command = "echo ${aws_instance.ubuntuEC2.private_ip} ansible_connection=local > inventory"
  }
}
resource "null_resource" "copy_inventory" {
  depends_on = [ # define the dependency for resource block execution
    null_resource.create_ansible_inventory
  ]
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.ubuntuEC2.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ubuntuEC2.private_key_pem
    }
    source      = "./inventory"
    destination = "/home/ubuntu/ansible/inventory"
  }
}
##########################################################

##########################################################
## blocks to copy and run ansible playbook
##########################################################
resource "null_resource" "copy_playbook" {
  triggers = {
    run_always = timestamp()
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.ubuntuEC2.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ubuntuEC2.private_key_pem
    }
    source      = "./playbooks/install.yaml"
    destination = "/home/ubuntu/ansible/install.yaml"
  }
}
resource "null_resource" "run_playbook" {
  depends_on = [
    null_resource.copy_playbook
  ]
  triggers = {
    run_always = timestamp()
  }
  provisioner "remote-exec" { # use to run defined commands in sequence on the remote server
    connection {              # connection details
      type        = "ssh"
      host        = aws_instance.ubuntuEC2.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.ubuntuEC2.private_key_pem
    }
    inline = [
      "sudo apt-get update -y",
      "sudo apt -y remove needrestart",
      "sudo apt-get install software-properties-common -y",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get install -y ansible",
      "sudo apt --fix-broken install -y",
      "ansible --version",
      "cd ~/ansible && ansible-playbook install.yaml"
    ]
  }
}
##########################################################

##########################################################
## blocks to check http link
##########################################################
provider "http" {} # https://registry.terraform.io/providers/hashicorp/http/3.1.0/docs/data-sources/http
data "http" "httpd" {
  depends_on = [
    null_resource.run_playbook
  ]
  url    = "http://${aws_instance.ubuntuEC2.public_ip}:80" # as we are referring EC2 ip, so this block will get executed after EC2 creation
  method = "HEAD"
}
##########################################################
