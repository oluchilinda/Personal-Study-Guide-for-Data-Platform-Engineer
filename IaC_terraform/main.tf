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

# Note that if you're using the --acl option, ensure that any associated IAM policies include the "s3:PutObjectAcl" action:
data "aws_iam_policy_document" "example" {
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = [aws_s3_bucket.bucket.arn]
  }
  statement {
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.bucket.arn]
    effect    = "Allow"
  }
  statement {
    actions   = ["s3:PutObject", "s3:PutObjectAcl", "s3:PutObjectTagging"]
    resources = [aws_s3_bucket.bucket.arn]
    effect    = "Allow"
    # principals {
    #   type        = "AWS"
    #   identifiers = [aws_iam_user.new_user.arn]
    # }

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
