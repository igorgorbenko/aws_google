#--------------------------------------------------------------
# AWS Lambda Roles: AuthorizerLambda_Role
#--------------------------------------------------------------
resource "aws_iam_role" "authorizer_lambda_role" {
  name = format("%s_%s", var.object_prefix, "AuthorizerLambda_Role")

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.default_tags
}


resource "aws_iam_policy" "authorizer_lambda_policy" {
  name = format("%s_%s", var.object_prefix, "AuthorizerLambda_Policy")
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cognito-identity:*",
                "cognito-idp:*",
                "cognito-sync:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "authorizer_lambda" {
  role       = aws_iam_role.authorizer_lambda_role.name
  policy_arn = aws_iam_policy.authorizer_lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "authorizer_lambda_2" {
  role       = aws_iam_role.authorizer_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#--------------------------------------------------------------
# AWS Lambda Roles: GoogleAPI_Role
#--------------------------------------------------------------
resource "aws_iam_role" "google_api_lambda_role" {
  name = format("%s_%s", var.object_prefix, "GoogleAPI_Role")

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.default_tags
}


resource "aws_iam_policy" "google_api_lambda_role_policy" {
  name = format("%s_%s", var.object_prefix, "GoogleAPI_Policy")
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:*",
                "logs:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "google_api_lambda_lambda" {
  role       = aws_iam_role.google_api_lambda_role.name
  policy_arn = aws_iam_policy.google_api_lambda_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "google_api_lambda_lambda_2" {
  role       = aws_iam_role.google_api_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

