locals {
  runtime = "python3.7"

  google_add_lambda_files = [
    "${path.module}/helpers/dynamo_db_helper.py",
    "${path.module}/helpers/google_api_helper.py",
    "${path.module}/lambda/google_contacts_add.py"
  ]

  google_list_lambda_files = [
    "${path.module}/helpers/dynamo_db_helper.py",
    "${path.module}/helpers/google_api_helper.py",
    "${path.module}/lambda/google_contacts_list.py"
  ]

  authorization_lambda_files = [
    "${path.module}/lambda/authorization_lambda.py"
  ]
}

#-----------------------------------------------------------
# LAMBDA LAYER
#-----------------------------------------------------------
resource "null_resource" "pip" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "${path.module}/setup/build_layer.sh"
  }
}

data "archive_file" "lambda_layer_archive" {
  type        = "zip"
  source_dir  = "${path.module}/setup/layer_google_api/src"
  output_path = "${path.module}/setup/layer_google_api/zip//google_api_layer.zip"

  depends_on = [null_resource.pip]
}

resource "aws_lambda_layer_version" "google_api" {
  filename            = data.archive_file.lambda_layer_archive.output_path
  layer_name          = "google_api_layer"
  source_code_hash    = data.archive_file.lambda_layer_archive.output_base64sha256
  compatible_runtimes = [local.runtime]
}

#-----------------------------------------------------------
# LAMBDA FUNCTION: authorization_lambda
#-----------------------------------------------------------
data "template_file" "authorization_t_file" {
  count = "${length(local.authorization_lambda_files)}"

  template = "${file(element(local.authorization_lambda_files, count.index))}"
}

resource "local_file" "authorization_to_temp_dir" {
  count    = length(local.authorization_lambda_files)
  filename = "${path.module}/setup/lambda/authorization/src/${basename(element(local.authorization_lambda_files, count.index))}"
  content  = element(data.template_file.authorization_t_file.*.rendered, count.index)

  depends_on = [
    data.template_file.authorization_t_file
  ]
}

data "archive_file" "authorization_zip" {
  type        = "zip"
  output_path = "${path.module}/setup/lambda/authorization/zip/authorization_lambda.zip"
  source_dir  = "${path.module}/setup/lambda/authorization/src"

  depends_on = [
    local_file.authorization_to_temp_dir
  ]
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
      # COGNITO_REGION = var.cognito_region
      CLIENT_ID      = var.cognito_user_pool_client_id
    }
  }

  tags = var.default_tags
}

#-----------------------------------------------------------
# LAMBDA FUNCTION: google_contacts_add
#-----------------------------------------------------------
data "template_file" "contacts_add_t_file" {
  count = "${length(local.google_add_lambda_files)}"

  template = "${file(element(local.google_add_lambda_files, count.index))}"
}

resource "local_file" "contacts_add_to_temp_dir" {
  count    = length(local.google_add_lambda_files)
  filename = "${path.module}/setup/lambda/google_contacts_add/src/${basename(element(local.google_add_lambda_files, count.index))}"
  content  = element(data.template_file.contacts_add_t_file.*.rendered, count.index)

  depends_on = [
    data.template_file.contacts_add_t_file
  ]
}

data "archive_file" "contacts_add_zip" {
  type        = "zip"
  output_path = "${path.module}/setup/lambda/google_contacts_add/zip/google_contacts_add.zip"
  source_dir  = "${path.module}/setup/lambda/google_contacts_add/src"

  depends_on = [
    local_file.contacts_add_to_temp_dir
  ]
}

resource "aws_lambda_function" "contacts_add" {
  function_name    = format("%s_%s", var.object_prefix, "google_contacts_add")
  filename         = data.archive_file.contacts_add_zip.output_path
  source_code_hash = data.archive_file.contacts_add_zip.output_base64sha256

  role        = aws_iam_role.google_api_lambda_role.arn
  handler     = "google_contacts_add.lambda_handler"
  runtime     = local.runtime
  timeout     = 60
  memory_size = 128

  layers = [aws_lambda_layer_version.google_api.arn]

  environment {
    variables = {
      LOG_TABLE_NAME = format("%s_%s", var.object_prefix, var.log_table_name)
    }
  }

  tags = var.default_tags
}

#-----------------------------------------------------------
# LAMBDA FUNCTION: google_contacts_list
#-----------------------------------------------------------
data "template_file" "contacts_list_t_file" {
  count = "${length(local.google_list_lambda_files)}"

  template = "${file(element(local.google_list_lambda_files, count.index))}"
}

resource "local_file" "contacts_list_to_temp_dir" {
  count    = length(local.google_add_lambda_files)
  filename = "${path.module}/setup/lambda/google_contacts_list/src/${basename(element(local.google_list_lambda_files, count.index))}"
  content  = element(data.template_file.contacts_list_t_file.*.rendered, count.index)

  depends_on = [
    data.template_file.contacts_list_t_file
  ]
}

data "archive_file" "contacts_list_zip" {
  type        = "zip"
  output_path = "${path.module}/setup/lambda/google_contacts_list/zip/google_contacts_list.zip"
  source_dir  = "${path.module}/setup/lambda/google_contacts_list/src"

  depends_on = [
    local_file.contacts_list_to_temp_dir
  ]
}

resource "aws_lambda_function" "contacts_list" {
  function_name    = format("%s_%s", var.object_prefix, "google_contacts_list")
  filename         = data.archive_file.contacts_list_zip.output_path
  source_code_hash = data.archive_file.contacts_list_zip.output_base64sha256

  role        = aws_iam_role.google_api_lambda_role.arn
  handler     = "google_contacts_list.lambda_handler"
  runtime     = local.runtime
  timeout     = 60
  memory_size = 128

  layers = [aws_lambda_layer_version.google_api.arn]

  tags = var.default_tags
}
