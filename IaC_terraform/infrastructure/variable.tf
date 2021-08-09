variable "region" {
  default = "us-west-1"
}
variable "bucket_name" {
  type    = string
  default = "oluchi-bucket-practise"
}
variable "iam_user" {
  default = "oluchipractise"
}
variable "policy_name" {
  default = "s3Policy"
}

# #redshift varedshift


# variable "redshift_cluster_identifier" {
#   default = "oluchi-cluster"
# }

# variable "TF_REDSHIFT_DB_NAME" {
#   type        = string
#   description = "this is an env variable export TF_REDSHIFT_DB_NAME"
# }
# variable "TF_REDSHIFT_DB_USERNAME" {
#   type        = string
#   description = "this is an env variable export TF_REDSHIFT_DB_USERNAME"

# }
# variable "TF_REDSHIFT_DB_PASSWORD" {
#   type        = string
#   description = "this is an env variable export TF_REDSHIFT_DB_PASSWORD"

# }



# variable "redshift_nodetype" {
#   description = "dc2.large"
# }
# variable "redshift_cluster_type" {
#   default = "single-node"
# }

# variable "vpc_cidr" {

#   default = "10.0.0.0/16"
# }

# variable "redshift_subnet_cidr_1" {
#   default = "10.0.1.0/24"
# }

# variable "redshift_subnet_cidr_2" {
#   default = "10.0.2.0/24"
# }
