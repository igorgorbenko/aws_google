#--------------------------------------------------------------
# AWS Lambda Roles
#--------------------------------------------------------------
resource "aws_iam_role" "authorizer_lambda_role" {
  name = format("%s_%s", var.object_prefix, "AuthorizerLambdaRole")

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
  name = format("%s_%s", var.object_prefix, "AuthorizerLambdaPolicy")
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

