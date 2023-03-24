provider "aws" {
  region = "us-east-2"
}

resource "aws_ami" "ubuntu" {
  owner = ""
  filter {
    name = "tag:Name"
    value= ["ubuntu"]
  }
  most_recent = true
}