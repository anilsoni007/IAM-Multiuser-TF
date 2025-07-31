/*
user defined roles mapping with aws managed policies.
*/

locals {
  user_role_mapping = {
    for user_map in local.users_info : user_map.username => user_map.roles
  }

  role_list = ["admin", "readonly", "billing", "audit"]
  user_roles = {
    readonly_role = ["ReadOnlyAccess"]
    admin_role    = ["AdministratorAccess"]
    billing_role  = ["Billing"]
    audit_role    = ["SecurityAudit"]
  }
  policy_list = flatten([for policy in values(local.user_roles) : policy])
}

data "aws_iam_policy" "managed_policies" {
  for_each = toset(local.policy_list)
  name     = each.value
}

resource "aws_iam_role_policy_attachment" "role_policy_attachments" {
  for_each   = { for role, policies in local.user_roles : role => policies[0] }
  role       = aws_iam_role.user_roles[each.key].name
  policy_arn = data.aws_iam_policy.managed_policies[each.value].arn
}

resource "aws_iam_role" "user_roles" {
  for_each           = local.user_roles
  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.iam_policy[replace(each.key, "_role", "")].json

}

data "aws_caller_identity" "current" {}



data "aws_iam_policy_document" "iam_policy" {
  for_each = toset([for role in local.role_list : role if length([for user, roles in local.user_role_mapping : user if contains([for r in roles : lower(r)], role)]) > 0])
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [for user, roles in local.user_role_mapping : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}" if contains([for r in roles : lower(r)], each.key)]
    }
  }
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "policy_list" {
  value = values(data.aws_iam_policy.managed_policies)[*].name
}

output "iam_roles_created" {
  value = keys(aws_iam_role.user_roles)
}

output "user_role_mapping" {
  value = local.user_role_mapping
}