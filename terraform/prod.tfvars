aws_region   = "us-east-1"
project_name = "url-shortener"
github_owner = "Ali-587"
infra_repo   = "url-shortener-infra"
app_repo     = "url-shortener-app"
alarm_email  = "alimcm587@gmail.com"
env_vars = {
  namespace = "url-shortener"
  stage     = "prod"
  name      = "main"
  delimiter = "-"
}