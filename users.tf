locals {
  users_info = yamldecode(file("${path.module}/users_info.yaml")).users
}


resource "aws_iam_user" "lb" {
  for_each = toset(local.users_info[*].username)
  name     = each.key
}

resource "aws_iam_user_login_profile" "example" {
  for_each                = aws_iam_user.lb
  user                    = each.key
  password_length         = 8
  password_reset_required = false
  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
}

output "users_info_output" {
  # value = local.users_info[*].username
  value = local.users_info
}

output "passwords" {
  sensitive = true
  value     = values(aws_iam_user_login_profile.example)[*].password
}
