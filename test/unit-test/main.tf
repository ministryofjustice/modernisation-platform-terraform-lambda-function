# lambda module test with image package type
module "module_test" {
  source                         = "../../"
  application_name               = local.application_name
  tags                           = local.tags
  description                    = "test lambda"
  role_name                      = format("InstanceSchedulerLambdaFunctionPolicy-%s", random_id.role.dec)
  policy_json_attached           = true
  policy_json                    = data.aws_iam_policy_document.instance-scheduler-lambda-function-policy.json
  function_name                  = format("instance-scheduler-lambda-function-%s", random_id.lambda.dec)
  create_role                    = true
  reserved_concurrent_executions = 1
  environment_variables = {
    "INSTANCE_SCHEDULING_SKIP_ACCOUNTS" = "nomis-development,nomis-test,nomis-preproduction,"
  }
  image_uri    = "${local.environment_management.account_ids["core-shared-services-production"]}.dkr.ecr.${data.aws_region.current_region.name}.amazonaws.com/instance-scheduler-ecr-repo:latest"
  timeout      = 600
  tracing_mode = "Active"

  allowed_triggers = {
    AllowStopExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.instance_scheduler_weekly_stop_at_night.arn
    }
    AllowStartExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.instance_scheduler_weekly_start_in_the_morning.arn
    }
  }

}

resource "aws_cloudwatch_event_rule" "instance_scheduler_weekly_stop_at_night" {
  name                = "instance_scheduler_weekly_stop_at_night"
  description         = "Call Instance Scheduler with Stop action at 8:00 pm (UTC) every Monday through Friday"
  schedule_expression = "cron(0 20 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "instance_scheduler_weekly_stop_at_night" {
  rule      = aws_cloudwatch_event_rule.instance_scheduler_weekly_stop_at_night.name
  target_id = "instance-scheduler-lambda-function"
  arn       = module.module_test.lambda_function_arn
  input = jsonencode(
    {
      action = "Stop"
    }
  )
}

resource "aws_cloudwatch_event_rule" "instance_scheduler_weekly_start_in_the_morning" {
  name                = "instance_scheduler_weekly_start_in_the_morning"
  description         = "Call Instance Scheduler with Start action at 5:00 am (UTC) every Monday through Friday"
  schedule_expression = "cron(0 5 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "instance_scheduler_weekly_start_in_the_morning" {
  rule      = aws_cloudwatch_event_rule.instance_scheduler_weekly_start_in_the_morning.name
  target_id = "instance-scheduler-lambda-function"
  arn       = module.module_test.lambda_function_arn
  input = jsonencode(
    {
      action = "Start"
    }
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "instance-scheduler-lambda-function-policy" {
  # checkov:skip=CKV_AWS_107: "Limiting required permissions"
  statement {
    sid    = "AllowLambdaToCreateLogGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      format("arn:aws:logs:eu-west-2:%s:aws/lambda/fake", data.aws_caller_identity.current.account_id)
    ]
  }
  statement {
    sid    = "AllowLambdaToWriteLogsToGroup"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      format("arn:aws:logs:eu-west-2:%s:*", data.aws_caller_identity.current.account_id)
    ]
  }
  statement {
    sid    = "EC2StopAndStart"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::*:role/InstanceSchedulerAccess"
    ]
  }
  statement {
    sid    = "AllowAccessParameter"
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      format("arn:aws:ssm:*:%s:parameter/environment_management_arn", data.aws_caller_identity.current.account_id)
    ]
  }
  statement {
    sid    = "AllowAccessEnvironmentManagementSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      format("arn:aws:secretsmanager:eu-west-2:%s:secret:environment_management*", local.environment_management.modernisation_platform_account_id)
    ]
  }
  # checkov:skip=CKV_AWS_111: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_109: "Cannot restrict by KMS alias so leaving open"
  # checkov:skip=CKV_AWS_356: "Cannot restrict by KMS alias so leaving open"
  statement {
    sid       = "AllowToDecryptKMS"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:Decrypt"]
  }
  statement {
    sid    = "s3Access"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "${module.s3-bucket.bucket.arn}/*",
      module.s3-bucket.bucket.arn
    ]
  }
}

resource "aws_lambda_invocation" "test_invocation" {
  function_name = module.module_test.lambda_function_name

  input = jsonencode({
    action = "Test"
  })
}

# lambda module test with zip package type and vpc config
module "lambda_function_in_vpc" {
  source           = "../../"
  application_name = local.application_name
  tags             = local.tags
  description      = "lambda function provisioned within a vpc test"
  lambda_role      = aws_iam_role.lambda-vpc-role.arn
  function_name    = format("lambda-function-in-vpc-test-%s", random_id.lambda_name.dec)
  create_role      = false
  package_type     = "Zip"
  filename         = data.archive_file.lambda-zip.output_path
  source_code_hash = data.archive_file.lambda-zip.output_base64sha256
  handler          = "test.lambda_handler"
  runtime          = "python3.12"

  vpc_subnet_ids         = [data.aws_subnet.private-2a.id]
  vpc_security_group_ids = [aws_security_group.lambda_security_group_test.id]
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-vpc-role" {
  name = format("LambdaFunctionVPCAccess-%s", random_id.role_name.dec)
  tags = local.tags

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda-vpc-attachment" {
  role       = aws_iam_role.lambda-vpc-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_vpc" "platforms-test" {
  id = "vpc-05900bb7e2e82391f"
}

data "aws_subnet" "private-2a" {
  id = "subnet-0e2a4d5f4b346c981"
}

resource "aws_security_group" "lambda_security_group_test" {
  # checkov:skip=CKV_AWS_382: "Only used for testing so minimal risk"
  name        = format("lambda-vpc-module-test-%s", random_id.sg_name.dec)
  description = "lambda attached to vpc test security group"
  vpc_id      = data.aws_vpc.platforms-test.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  tags = local.tags
}

data "archive_file" "lambda-zip" {
  type        = "zip"
  source_file = "test-zip/test.py"
  output_path = "test.zip"
}

resource "aws_lambda_invocation" "test_vpc_invocation" {
  function_name = module.lambda_function_in_vpc.lambda_function_name

  input = jsonencode({
    action = "Test"
  })
}

# random IDs to allow for go unit test to run to completion via github action 

resource "random_id" "lambda_name" {
  byte_length = 1
}

resource "random_id" "role" {
  byte_length = 1
}

resource "random_id" "lambda" {
  byte_length = 1
}

resource "random_id" "sg_name" {
  byte_length = 1
}

resource "random_id" "role_name" {
  byte_length = 1
}
