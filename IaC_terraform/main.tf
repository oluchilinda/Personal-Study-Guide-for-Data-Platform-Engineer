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
  name = var.iam_user
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name        = "bucket practise"
    Environment = "Dev"
  }
}

data "aws_iam_policy_document" "example" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.bucket.arn]
  }
}


resource "aws_iam_policy" "policy" {
  name        = var.policy_name
  description = "My test policy for datawarehouse in cloud"

  policy = data.aws_iam_policy_document.example.json

}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.new_user.name
  policy_arn = aws_iam_policy.policy.arn
}