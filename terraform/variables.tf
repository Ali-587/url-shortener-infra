variable "aws_region" {
  description = "AWS region for regional resources"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "url-shortener"
}

variable "lambda_runtime" {
  description = "Node.js Lambda runtime"
  type        = string
  default     = "nodejs22.x"
}

variable "lambda_memory_size" {
  description = "Lambda memory size"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Lambda timeout"
  type        = number
  default     = 10
}

variable "environment" {
  description = "Environment name such as dev or prod"
  type        = string
  default     = "dev"
}