locals {
  runtime = "python3.7"
}

#-----------------------------------------------------------
# LAMBDA LAYER
#-----------------------------------------------------------
resource "null_resource" "pip" {
  triggers = {
    requirements = filebase64sha256("../${path.module}/requirements.txt")
    execute      = filebase64sha256("../${path.module}/pip.sh")
  }

  provisioner "local-exec" {
    command = "../${path.module}/pip.sh ../${path.module}/"
  }
}

data "archive_file" "lambda_layer_archive" {
  type        = "zip"
  source_dir  = "../${path.module}/temp/layer"
  output_path = "../${path.module}/temp/google_api_layer.zip"

  depends_on = [null_resource.pip]
}

resource "aws_lambda_layer_version" "google_api" {
  filename            = data.archive_file.lambda_layer_archive.output_path
  layer_name          = "google_api"
  source_code_hash    = data.archive_file.lambda_layer_archive.output_base64sha256
  compatible_runtimes = [local.runtime]
}

#-----------------------------------------------------------
# LAMBDA FUNCTION
#-----------------------------------------------------------
data "archive_file" "authorization_zip" {
  source_file = "../${path.module}/lambda/authorization_lambda.py"
  type        = "zip"
  output_path = "../${path.module}/lambda/authorization_lambdazip"
}

resource "aws_lambda_function" "authorization" {
  function_name    = format("%s_%s", var.object_prefix, "authorization_lambda")
  filename         = data.archive_file.authorization_zip.output_path
  source_code_hash = data.archive_file.authorization_zip.output_base64sha256

  role        = aws_iam_role.authorizer_lambda_role.arn
  handler     = "authorization_lambda.lambda_handler"
  runtime     = local.runtime
  timeout     = 60
  memory_size = 128

  environment {
    variables = {
      USER_POOL_ID = ""
      CLIENT_ID    = ""
    }
  }

  tags = var.default_tags
}



# google_contacts_lambda