#--------------------------------------------------------------
# Cognito User Pool
#--------------------------------------------------------------

data "aws_cognito_user_pools" "selected_user_pool" {
  name = var.cognito_user_pool_name
}

