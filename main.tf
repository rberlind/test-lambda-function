terraform {
  required_version = ">= 0.11.10"
}

variable "aws_region" {
  description = "AWS region"
  default = "us-east-1"
}

variable "lambda_function_name" {
  description = "name of Lambda function"
  default = "roger-test-lambda"
}

variable "aws_account_id" {
  description = "ID of your AWS account"
  default = "753646501470"
}

variable "iam_role_name" {
  description = "name of IAM role"
  default = "roger-lambda-role"
}

variable "iam_basic_execution_policy" {
  description = "name of basic execution policy"
  default = "roger-basic-lambda-policy"

}

variable "iam_vpc_access_policy" {
  description = "name of vpc access policy"
  default = "roger-lambda-vpc_access-policy"
}

variable "kms_key" {
  description = "arn of KMS key"
  default = "arn:aws:kms:us-east-1:753646501470:key/00c892e8-40c4-4048-a650-0f755876503d"
}

variable "security_group_id" {
  description = "ID of security group"
  default = "sg-0787742bcf636219f"
}

variable "subnet_id" {
  description = "ID of subnet"
  default = "subnet-0d18b4a4c737d6a48"
}

variable "iam_kms_lambda_policy" {
  description = "name of KMS Lambda policy"
  default = "roger-lambda-kms-policy"
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_iam_role" "role_for_lambda" {
  name = "${var.iam_role_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_basic_execution" {
    name        = "${var.iam_basic_execution_policy}"
    description = "A basic lambda policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:*:*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_basic_lambda" {
    role       = "${aws_iam_role.role_for_lambda.name}"
    policy_arn = "${aws_iam_policy.lambda_basic_execution.arn}"
}

resource "aws_iam_policy" "lambda_kms" {
    name        = "${var.iam_kms_lambda_policy}"
    description = "A kms lambda policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kms:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_kms_lambda" {
    role       = "${aws_iam_role.role_for_lambda.name}"
    policy_arn = "${aws_iam_policy.lambda_kms.arn}"
}

resource "aws_iam_policy" "lambda_vpc_access" {
    name        = "${var.iam_vpc_access_policy}"
    description = "A lambda vpc access policy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_lambda_vpc_access" {
    role       = "${aws_iam_role.role_for_lambda.name}"
    policy_arn = "${aws_iam_policy.lambda_vpc_access.arn}"
}

resource "aws_lambda_function" "test_lambda" {
  filename         = "app.zip"
  function_name    = "${var.lambda_function_name}"
  role             = "${aws_iam_role.role_for_lambda.arn}"
  handler          = "app.handler"
  source_code_hash = "${base64sha256(file("app.zip"))}"
  runtime          = "python2.7"
  kms_key_arn      = "${var.kms_key}"

  vpc_config {
    subnet_ids = []
    security_group_ids = []
  }

  environment {
    variables = {
      my_secret = "AQICAHhj5kWyeprUqLbu+1gkK2UeO5WuwRcjaI/IG27Us8zBRwHH745dQMacM8zkqhaRNB7cAAAAbDBqBgkqhkiG9w0BBwagXTBbAgEAMFYGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM/QPGAjv5Ak2faX6aAgEQgCm+snwc3SmmGGpAc6kahKKnOCZFWkg4hA3OpYt7Pp0yDGb9JYJJjDX9Nw=="
    }
  }

}

output "kms_key_arn" {
  value = "${aws_lambda_function.test_lambda.kms_key_arn}"
}
