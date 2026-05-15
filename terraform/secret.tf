resource "random_password" "cloudfront_secret" {
  length  = 32
  special = false
}