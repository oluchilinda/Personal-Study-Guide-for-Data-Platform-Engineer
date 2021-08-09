terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}


resource "aws_iam_user" "new_user" {
  name          = var.iam_name
  path          = "/"
  force_destroy = true

}

resource "aws_iam_user_login_profile" "new_user" {
  user                    = aws_iam_user.new_user.name
  pgp_key                 = "keybase:${var.KEYBASE_USERNAME}"
  password_reset_required = true
  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
}


resource "aws_iam_user_policy" "password_change" {
  name = "test"
  user = aws_iam_user.new_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "iam:GetAccountPasswordPolicy",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:ChangePassword",
        "Resource" : "arn:aws:iam::${var.account_id}:user/${var.iam_name}"
      }
    ]
  })
}

resource "aws_iam_user_policy" "security_keys_access" {
  name = "test"
  user = aws_iam_user.new_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Sid" : "ListUsersForConsole",
        "Effect" : "Allow",
        "Action" : "iam:ListUsers",
        "Resource" : "arn:aws:iam::*:*"
      },
      {
        "Sid" : "ViewAndUpdateAccessKeys",
        "Effect" : "Allow",
        "Action" : [
          "iam:UpdateAccessKey",
          "iam:CreateAccessKey",
          "iam:ListAccessKeys"
        ],
        "Resource" : "arn:aws:iam::${var.account_id}:user/${var.iam_name}"
      }
    ]
  })
}
