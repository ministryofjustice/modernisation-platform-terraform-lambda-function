
module "module_test" {
  source                         = "../../"
  application_name               = local.application_name
  tags                           = local.tags
  description                    = "test lambda"
  role_name                      = "InstanceSchedulerLambdaFunctionPolicy"
  policy_json                    = data.aws_iam_policy_document.instance-scheduler-lambda-function-policy.json
  function_name                  = "instance-scheduler-lambda-function"
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
      format("arn:aws:logs:eu-west-2:%s:*", data.aws_caller_identity.current.account_id)
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
  statement {
    sid       = "AllowToDecryptKMS"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:Decrypt"]
  }
}

resource "aws_lambda_invocation" "test_invocation" {
  function_name = module.module_test.lambda_function_name

  input = jsonencode(
    {
      action = "Test"
  })
}