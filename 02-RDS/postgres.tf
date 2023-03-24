variable "roles" {
  default = ["dev","test","prod"]
}

resource "random_password" "role_password" {
  for_each = toset(var.roles)
  length = 8
  upper = true
  numeric = true
}
resource "postgresql_role" "role" {
  for_each = toset(var.roles)
  name     = each.value
  login    = true
  password = random_password.role_password[each.value].result
}