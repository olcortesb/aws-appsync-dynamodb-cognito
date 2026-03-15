variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name used as prefix for resources"
  type        = string
  default     = "appsync-demo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "cognito_callback_url" {
  description = "Cognito Hosted UI callback URL"
  type        = string
  default     = "https://localhost:3000/callback"
}

variable "cognito_logout_url" {
  description = "Cognito Hosted UI logout URL"
  type        = string
  default     = "https://localhost:3000"
}
