#-----------------------------------------------------------
# API Gateway: coogle_contact
#-----------------------------------------------------------
resource "aws_api_gateway_rest_api" "aws_google_api" {
  name = format("%s_%s", var.object_prefix, "google_contacts")
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# resource "aws_api_gateway_authorizer" "google_contact_auth" {
#   name = format("%s_%s", var.object_prefix, "cognito_authorizer")
#   type = "COGNITO_USER_POOLS"
#   rest_api_id = aws_api_gateway_rest_api.aws_google_api.id
#   provider_arns = data.aws_cognito_user_pools.selected_user_pool
# }

#-----------------------------------------------------------
# OAUTH
#-----------------------------------------------------------
resource "aws_api_gateway_resource" "oauth" {
  path_part   = "oauth"
  parent_id   = aws_api_gateway_rest_api.aws_google_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.aws_google_api.id
}

resource "aws_api_gateway_resource" "token" {
  path_part   = "token"
  parent_id   = aws_api_gateway_resource.oauth.id
  rest_api_id = aws_api_gateway_rest_api.aws_google_api.id
}

# POST method
resource "aws_api_gateway_method" "token_post" {
  rest_api_id   = aws_api_gateway_rest_api.aws_google_api.id
  resource_id   = aws_api_gateway_resource.token.id
  http_method   = "POST"
  authorization = "NONE"
  # authorization = "COGNITO_USER_POOLS"
  # authorizer_id = aws_api_gateway_authorizer.google_contact_auth.id

  request_parameters = {
    "method.request.path.proxy" = false
  }
}

resource "aws_api_gateway_integration" "token_integration" {
  rest_api_id             = aws_api_gateway_rest_api.aws_google_api.id
  resource_id             = aws_api_gateway_resource.token.id
  http_method             = aws_api_gateway_method.token_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.authorization.invoke_arn
}

resource "aws_lambda_permission" "authorization" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorization.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.aws_google_api.id}/*/${aws_api_gateway_method.token_post.http_method}${aws_api_gateway_resource.token.path}"
}

resource "aws_api_gateway_integration_response" "authorization_resp" {
  rest_api_id = aws_api_gateway_rest_api.aws_google_api.id
  resource_id = aws_api_gateway_resource.token.id
  http_method = aws_api_gateway_method.token_post.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.token_integration
  ]
}

resource "aws_api_gateway_method_response" "authorization_resp" {
  rest_api_id = aws_api_gateway_rest_api.aws_google_api.id
  resource_id = aws_api_gateway_resource.token.id
  http_method = aws_api_gateway_method.token_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_integration_response.authorization_resp
  ]
}

#-----------------------------------------------------------
# Google Contacts: POST
#-----------------------------------------------------------
resource "aws_api_gateway_resource" "google_contacts" {
  path_part   = "{google-contacts+}"
  parent_id   = aws_api_gateway_rest_api.aws_google_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.aws_google_api.id
}

# POST method
resource "aws_api_gateway_method" "google_contacts_post" {
  rest_api_id   = aws_api_gateway_rest_api.aws_google_api.id
  resource_id   = aws_api_gateway_resource.google_contacts.id
  http_method   = "POST"
  authorization = "NONE"
  # authorization = "COGNITO_USER_POOLS"
  # authorizer_id = aws_api_gateway_authorizer.google_contact_auth.id

  request_parameters = {
    "method.request.path.proxy" = false
  }
}

resource "aws_api_gateway_integration" "google_contacts_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.aws_google_api.id
  resource_id             = aws_api_gateway_resource.google_contacts.id
  http_method             = aws_api_gateway_method.google_contacts_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contacts_add.invoke_arn
}

resource "aws_lambda_permission" "google_contacts_post" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contacts_add.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.aws_google_api.id}/*/${aws_api_gateway_method.google_contacts_post.http_method}${aws_api_gateway_resource.google_contacts.path}"
}

resource "aws_api_gateway_integration_response" "google_contacts_post_resp" {
  rest_api_id = aws_api_gateway_rest_api.aws_google_api.id
  resource_id = aws_api_gateway_resource.google_contacts.id
  http_method = aws_api_gateway_method.google_contacts_post.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.google_contacts_post_integration
  ]
}

resource "aws_api_gateway_method_response" "google_contacts_post_resp" {
  rest_api_id = aws_api_gateway_rest_api.aws_google_api.id
  resource_id = aws_api_gateway_resource.google_contacts.id
  http_method = aws_api_gateway_method.google_contacts_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_integration_response.google_contacts_post_resp
  ]
}

#-----------------------------------------------------------
# Google Contacts: GET
#-----------------------------------------------------------
# GET method
resource "aws_api_gateway_method" "google_contacts_get" {
  rest_api_id   = aws_api_gateway_rest_api.aws_google_api.id
  resource_id   = aws_api_gateway_resource.google_contacts.id
  http_method   = "GET"
  authorization = "NONE"
  # authorization = "COGNITO_USER_POOLS"
  # authorizer_id = aws_api_gateway_authorizer.google_contact_auth.id

  request_parameters = {
    "method.request.path.proxy" = false
  }
}

resource "aws_api_gateway_integration" "google_contacts_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.aws_google_api.id
  resource_id             = aws_api_gateway_resource.google_contacts.id
  http_method             = aws_api_gateway_method.google_contacts_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contacts_list.invoke_arn
}

resource "aws_lambda_permission" "google_contacts_get" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contacts_list.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.aws_google_api.id}/*/${aws_api_gateway_method.google_contacts_get.http_method}${aws_api_gateway_resource.google_contacts.path}"
}

resource "aws_api_gateway_integration_response" "google_contacts_get_resp" {
  rest_api_id = aws_api_gateway_rest_api.aws_google_api.id
  resource_id = aws_api_gateway_resource.google_contacts.id
  http_method = aws_api_gateway_method.google_contacts_get.http_method
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.google_contacts_get_integration
  ]
}

resource "aws_api_gateway_method_response" "google_contacts_get_resp" {
  rest_api_id = aws_api_gateway_rest_api.aws_google_api.id
  resource_id = aws_api_gateway_resource.google_contacts.id
  http_method = aws_api_gateway_method.google_contacts_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_integration_response.google_contacts_get_resp
  ]
}
