variable "aws_region" {
  default = "us-east-2"
}

variable "aws_account_id" {
  default = "985272430082"
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

# variable "cognito_user_pool_name" {
#   type = string
# }

variable "cognito_user_pool_client_id" {
  default = "2qdp9a19798t1355drvm60gnj7"
}

variable "cognito_region" {
  default = "us-east-1"
}

variable "log_table_name" {
  default = "google_log_table"
}