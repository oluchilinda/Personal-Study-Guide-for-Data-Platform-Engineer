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

resource "aws_iam_user_policy" "secret_keys_access" {
  name = "secret-keys-access"
  user = aws_iam_user.new_user.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "CreateOwnAccessKeys",
        "Action" : [
          "iam:CreateAccessKey",
          "iam:GetUser",
          "iam:ListAccessKeys"

        ],
        "Effect" : "Allow",
        "Resource" : ["arn:aws:iam::${var.account_id}:user/${var.iam_name}"]
      },
    ]
  })
}

resource "aws_iam_user_policy" "cloudwatch_full_access" {
  name ="cloudwatch-access"
  user = aws_iam_user.new_user.name

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:Describe*",
                "cloudwatch:*",
                "logs:*",
                "ssm-incidents:ListResponsePlans",
                "sns:*",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": [
                        "events.amazonaws.com",
                        "ssm.alarms.cloudwatch.amazonaws.com",
                        "ssm-incidents.alarms.cloudwatch.amazonaws.com"
                    ]
                }
            }
        }
    ]

  })
  
}

resource "aws_iam_user_policy" "password_access" {
  name = "password-access"
  user = aws_iam_user.new_user.name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "iam:GetAccountPasswordPolicy",
          "iam:ChangePassword",
          "iam:CreateRole",
          "iam:PutRolePolicy",
          "iam:CreateInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:ListRoles",
          "iam:GetPolicy",
          "iam:GetInstanceProfile",
          "iam:GetPolicyVersion",
          "iam:AttachRolePolicy",
          "iam:PassRole"
          

        ],
        "Effect" : "Allow",
        "Resource" : ["arn:aws:iam::${var.account_id}:user/${var.iam_name}"]
      },
      {
      "Effect": "Allow",
      "Action": [
            "iam:GetRole",
            "iam:PassRole",
            "iam:CreateServiceLinkedRole"
        ],
      "Resource": ["${aws_iam_role.redshift_role.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
            "iam:CreateServiceLinkedRole"
        ],
      "Resource": ["arn:aws:iam::${var.account_id}:role/aws-service-role/redshift.amazonaws.com/AWSServiceRoleForRedshift"]
    },
    ]
  })
}


resource "aws_iam_policy" "redshift_access" {
  name = "redshift-access"
  policy = jsonencode({
    "Version" : "2012-10-17",
    Statement : [
      {
        "Sid" : "AllowClusterManagement"
        "Action" : [
          "redshift:*",
          "redshift:CreateCluster",
          "redshift:DeleteCluster",
          "redshift:ModifyCluster",
          "redshift:RebootCluster",
          "redshift:CreateClusterSubnetGroup",
          "redshift:CreateTags",
          "redshift:DescribeClusters",
          "redshift:DescribeClusterSubnetGroups",
          "redshift:DeleteClusterSubnetGroup",
          "redshift:DescribeLoggingStatus"

        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      
    ]
  })
}


resource "aws_iam_policy" "vpc_access" {
  name = "vpc-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:CreateVpc",
          "ec2:DeleteVpc",
          "ec2:CreateSubnet",
          "ec2:ModifySubnetAttribute",
          "ec2:DeleteSubnet",
          "ec2:DescribeAvailabilityZones",
          "ec2:CreateRouteTable",
          "ec2:CreateRoute",
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:AssociateRouteTable",
          "ec2:ModifyVpcAttribute",
          "ec2:CreateTags",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
          "ec2:ModifySecurityGroupRules",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteRouteTable",
          "ec2:CreateRoute",
          "ec2:ReplaceRoute",
          "ec2:DeleteRoute"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_s3_bucket" "bucket_name" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}




resource "aws_iam_role" "s3buckets" {
  name               = "s3buckets_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${var.account_id}:user/${var.iam_name}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "redshift_role" {
  name = "redshift_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${var.account_id}:user/${var.iam_name}"
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "redshift.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
    
  ]
}
EOF
}



resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
          "s3:ListAllMyBuckets",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_policy_attachment" "s3-attach" {
  name       = "s3-attachment"
  users      = [aws_iam_user.new_user.name]
  roles      = [aws_iam_role.s3buckets.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy_attachment" "vpc-attach" {
  name       = "vpc-attachment"
  users      = [aws_iam_user.new_user.name]
  policy_arn = aws_iam_policy.vpc_access.arn
}


resource "aws_iam_policy_attachment" "redshift-attach" {
  name       = "redshift-attachment"
  users      = [aws_iam_user.new_user.name]
  roles      = [aws_iam_role.redshift_role.name]
  policy_arn = aws_iam_policy.redshift_access.arn
}

