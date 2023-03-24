provider "aws" {
  region = "us-east-2"
}
provider "random" {

}
provider "postgresql" {
  host     = aws_db_instance.postgres.address
  port     = 5432
  database = "postgres"
  username = aws_db_instance.postgres.username
  password = aws_db_instance.postgres.password
  superuser = false
}