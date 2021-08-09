

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


resource "aws_s3_bucket" "bucket-name" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "redshift-vpc"
  }
}

resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main.id


  depends_on = [aws_vpc.main]

  
}

resource "aws_subnet" "redshift_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.redshift_subnet_cidr_1
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "redshift-subnet-1"
  }

  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_subnet" "redshift_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.redshift_subnet_cidr_2
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "redshift-subnet-2"
  }

  depends_on = [
    aws_vpc.main
  ]
}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "redshift-subnet-group"
  subnet_ids = [aws_subnet.redshift_subnet_1.id, aws_subnet.redshift_subnet_2.id]

  tags = {
    environment = "dev"
    Name        = "redshift-subnet-group"
  }
}

resource "aws_default_security_group" "redshift_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redshift-sg"
  }

  depends_on = [
    aws_vpc.main
  ]
}



resource "aws_redshift_cluster" "default" {
  cluster_identifier        = var.redshift_cluster_identifier
  database_name             = var.redshift_database_name
  master_username           = var.redshift_master_username
  master_password           = var.redshift_master_pass
  node_type                 = var.redshift_nodetype
  cluster_type              = var.redshift_cluster_type
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.id
  skip_final_snapshot       = true

    depends_on = [
    aws_vpc.main,
    aws_default_security_group.redshift_security_group,
    aws_redshift_subnet_group.redshift_subnet_group,
    
  ]

}