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

  # Create a VPC with a public subnet
  statement {
  sid = "VpcAccess"
  actions =[
    "ec2:CreateVpc", 
    "ec2:CreateSubnet", 
    "ec2:DescribeAvailabilityZones",
    "ec2:CreateRouteTable", 
    "ec2:CreateRoute", 
    "ec2:CreateInternetGateway", 
    "ec2:AttachInternetGateway", 
    "ec2:AssociateRouteTable", 
    "ec2:ModifyVpcAttribute",
    "ec2:CreateTags"
    
  ]
   resources = [
      "*"
    ]
}
#Modify and delete VPC resources
statement{
  effect =  "Allow"
  actions =  ["ec2:DeleteInternetGateway"]
  resources = ["arn:aws:ec2:*:*:internet-gateway/*"]
}
statement {
  effect = "Allow"
  actions = [
      "ec2:DeleteRouteTable",
      "ec2:CreateRoute",
      "ec2:ReplaceRoute",
      "ec2:DeleteRoute"
  ]
  resources =  ["arn:aws:ec2:*:*:route-table/*"]
}

# Manage security groups
statement {
  effect = "Allow"
  actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
      "ec2:ModifySecurityGroupRules",
      "ec2:DeleteSecurityGroup" 
  ]
  resources =  ["arn:aws:ec2:*:*:security-group/*"]
}


}

resource "aws_iam_policy" "policy" {
  name        = "pipelinepolicies"
  description = "My test policy for datawarehouse in cloud"

  policy = data.aws_iam_policy_document.example.json

}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.new_user.name
  policy_arn = aws_iam_policy.policy.arn
}


