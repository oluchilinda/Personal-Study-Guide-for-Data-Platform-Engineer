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
  force_destroy = true
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"
  force_destroy = true


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

# # provision redshift
# resource "aws_vpc" "redshift_vpc" {
#   cidr_block       = "${var.vpc_cidr}"
#   instance_tenancy = "default"

#   tags = {
#     Name = "redshift-vpc"
#   }
# }

# resource "aws_internet_gateway" "redshift_vpc_gw" {
#   vpc_id = "${aws_vpc.redshift_vpc.id}"

#   depends_on = [
#     "aws_vpc.redshift_vpc"
#   ]
# }

# resource "aws_subnet" "redshift_subnet_1" {
#   vpc_id                  = "${aws_vpc.redshift_vpc.id}"
#   cidr_block              = "${var.redshift_subnet_cidr_1}"
#   availability_zone       = "us-west-2a"
#   map_public_ip_on_launch = "true"

#   tags = {
#     Name = "redshift-subnet-1"
#   }

#   depends_on = [
#     "aws_vpc.redshift_vpc"
#   ]
# }

# resource "aws_subnet" "redshift_subnet_2" {
#   vpc_id                  = "${aws_vpc.redshift_vpc.id}"
#   cidr_block              = "${var.redshift_subnet_cidr_2}"
#   availability_zone       = "us-west-2b"
#   map_public_ip_on_launch = "true"

#   tags = {
#     Name = "redshift-subnet-2"
#   }

#   depends_on = [
#     "aws_vpc.redshift_vpc"
#   ]
# }

# resource "aws_redshift_subnet_group" "redshift_subnet_group" {
#   name       = "redshift-subnet-group"
#   subnet_ids = ["${aws_subnet.redshift_subnet_1.id}", "${aws_subnet.redshift_subnet_2.id}"]

#   tags = {
#     environment = "dev"
#     Name        = "redshift-subnet-group"
#   }
# }

# resource "aws_default_security_group" "redshift_security_group" {
#   vpc_id = "${aws_vpc.redshift_vpc.id}"

#   ingress {
#     from_port   = 5439
#     to_port     = 5439
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "redshift-sg"
#   }

#   depends_on = [
#     "aws_vpc.redshift_vpc"
#   ]
# }


# resource "aws_iam_role" "redshift_role" {
#   name = "redshift_role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "redshift.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF

#   tags = {
#     tag-key = "redshift-role"
#   }
# }

# resource "aws_redshift_cluster" "default" {
#   cluster_identifier        = "${var.rs_cluster_identifier}"
#   database_name             = "${var.rs_database_name}"
#   master_username           = "${var.rs_master_username}"
#   master_password           = "${var.rs_master_pass}"
#   node_type                 = "${var.rs_nodetype}"
#   cluster_type              = "${var.rs_cluster_type}"
#   cluster_subnet_group_name = "${aws_redshift_subnet_group.redshift_subnet_group.id}"
#   skip_final_snapshot       = true
#   iam_roles                 = ["${aws_iam_role.redshift_role.arn}"]

#   depends_on = [
#     "aws_vpc.redshift_vpc",
#     "aws_default_security_group.redshift_security_group",
#     "aws_redshift_subnet_group.redshift_subnet_group",
#     "aws_iam_role.redshift_role"
#   ]
# }