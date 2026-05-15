terraform {
  backend "s3" {
    bucket       = "url-shortener-terraform-state-bucket"
    key          = "url-shortener/dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
