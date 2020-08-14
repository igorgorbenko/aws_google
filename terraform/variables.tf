variable "aws_region" {
  default = "us-east-2"
}

variable "aws_profile" {
  default = "default"
}

variable "default_tags" {
  type = map(string)
  default = {
    project : "aws_google",
    env : "dev"
  }
}

variable "object_prefix" {
  default = "show"
}

variable "cognito_user_pool_name" {
  type = string
}