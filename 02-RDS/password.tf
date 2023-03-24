resource "random_password" "dbPassword" {
  length           = 10
  special          = true
  upper            = true
  lower            = true
  numeric          = true
  override_special = "_*!"
}

resource "aws_secretsmanager_secret" "dbPassword" {
  name                    = var.name
  recovery_window_in_days = 0
  description             = "RDS Database Secret Managed by Terraform for ${var.name}"
}
resource "aws_secretsmanager_secret_version" "dbPassword" {
  secret_id     = aws_secretsmanager_secret.dbPassword.id
  secret_string = random_password.dbPassword.result
}