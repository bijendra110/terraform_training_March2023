variable "name" {
  description = "Enter the value to be used with Name tag and Namr arguments"
}
variable "cidr_block" {
  default = "10.10.0.0/16"
}

variable "private_subnet_start" {
  type = string
}
variable "public_subnet_start" {
  type = string
}