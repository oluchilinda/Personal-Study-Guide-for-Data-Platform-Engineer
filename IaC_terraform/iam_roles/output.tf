
# output "password" {
#   value = "${aws_iam_user_login_profile.new_user.encrypted_password}"
# }
output "iam_arn" {
  value = aws_iam_user.new_user.arn
}

output "rendered_policy" {
  value = data.aws_iam_policy_document.example.json
}