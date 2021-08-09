variable "region" {
  default = "us-west-1"
}
variable "iam_name" {
  type    = string
}
variable "KEYBASE_USERNAME" {
  type        = string
  description = "this is an env variable export TF_VAR_KEYBASE_USERNAME"
}

variable "account_id" {

}


