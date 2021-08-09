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

data "aws_iam_policy_document" "example" {
  # s3 policies
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
  statement {
    actions   = ["s3:*"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions   = ["s3:PutObject", "s3:PutObjectAcl", "s3:PutObjectTagging"]
    resources = ["*"]
    effect    = "Allow"
  }

  # password change
  statement {
    actions   = ["iam:GetAccountPasswordPolicy"]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:ChangePassword"]
    resources = ["arn:aws:iam::${var.account_id}:user/${var.iam_name}"]
  }

  # security keys access
  statement {
    sid       = "ListUsersForConsole"
    effect    = "Allow"
    actions   = ["iam:ListUsers"]
    resources = ["arn:aws:iam::*:*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:ChangePassword"]
    resources = ["arn:aws:iam::${var.account_id}:user/${var.iam_name}"]
  }
  # reshift
  statement {
    sid = "AllowClusterManagement"
    actions = [
      "redshift:CreateCluster",
      "redshift:DeleteCluster",
      "redshift:ModifyCluster",
      "redshift:RebootCluster"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }

}

resource "aws_iam_policy" "policy" {
  name        = "pipeline-policies"
  description = "My test policy for datawarehouse in cloud"

  policy = data.aws_iam_policy_document.example.json

}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.new_user.name
  policy_arn = aws_iam_policy.policy.arn
}


# resource "aws_iam_user_policy" "password_change" {
#   name = "password-access"
#   user = aws_iam_user.new_user.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : "iam:GetAccountPasswordPolicy",
#         "Resource" : "*"
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : "iam:ChangePassword",
#         "Resource" : "arn:aws:iam::${var.account_id}:user/${var.iam_name}"
#       }
#     ]
#   })
# }

# resource "aws_iam_user_policy" "security_keys_access" {
#   name = "access-key-profile"
#   user = aws_iam_user.new_user.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     "Statement" : [
#       {
#         "Sid" : "ListUsersForConsole",
#         "Effect" : "Allow",
#         "Action" : "iam:ListUsers",
#         "Resource" : "arn:aws:iam::*:*"
#       },
#       {
#         "Sid" : "ViewAndUpdateAccessKeys",
#         "Effect" : "Allow",
#         "Action" : [
#           "iam:UpdateAccessKey",
#           "iam:CreateAccessKey",
#           "iam:ListAccessKeys"
#         ],
#         "Resource" : "arn:aws:iam::${var.account_id}:user/${var.iam_name}"
#       }
#     ]
#   })
# }

# resource "aws_iam_user_policy" "s3" {
#   name = "s3-policy"
#   user = aws_iam_user.new_user.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     "Statement" : [
#       {
#         "Sid" : "updateS3",
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : "arn:aws:iam::${var.account_id}:user/${var.iam_name}"
#         },
#         "Action" : [
#           "s3:PutObject",
#           "s3:PutObjectAcl"
#         ],
#         "Resource" : "*"
#       },
#       {
#         "Sid" : "",
#         "Action" : [
#           "s3:ListAllMyBuckets"
#         ],
#         "Resource" : "*"
#       },
#       {
#         "Sid" : "",
#         "Effect" : "Allow",
#         "Action" : [
#           "s3:*"
#         ],
#         "Resource" : "*"
#       },

#     ]
#   })
# }


# resource "aws_iam_user_policy" "redshift_cluster" {
#   name = "redshift-policy"
#   user = aws_iam_user.new_user.name

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Action" : "sts:AssumeRole",
#         "Principal" : {
#           "Service" : "redshift.amazonaws.com"
#         },
#         "Effect" : "Allow",
#         "Sid" : ""
#       }
#     ]
#   })
# }





