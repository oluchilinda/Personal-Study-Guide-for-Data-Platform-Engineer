variable "region" {
  default = "us-west-1"
}
variable "bucket_name" {
  type = string
  default = "oluchi-bucket-practise"
}
variable "iam_user" {
  default = "oluchipractise"
}
variable "policy_name" {
  default = "s3Policy"
  }
