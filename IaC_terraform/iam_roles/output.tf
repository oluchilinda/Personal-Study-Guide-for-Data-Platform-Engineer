
output "password" {
  value = "${aws_iam_user_login_profile.new_user.encrypted_password}"
}
output "iam_arn" {
  value = aws_iam_user.new_user.arn
}