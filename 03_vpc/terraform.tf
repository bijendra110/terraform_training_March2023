terraform {
  backend "s3" {
    region = "us-east-2"
    bucket = "kulbhushanmayer"
    key    = "ibm/IaC/mar-2023/bijendra.tfstate"
  }
}