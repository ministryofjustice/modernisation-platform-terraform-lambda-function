# Modernisation Platform Terraform Module Template

[![repo standards badge](https://img.shields.io/badge/dynamic/json?color=blue&style=for-the-badge&logo=github&label=MoJ%20Compliant&query=%24.result&url=https%3A%2F%2Foperations-engineering-reports.cloud-platform.service.justice.gov.uk%2Fapi%2Fv1%2Fcompliant_public_repositories%2Fmodernisation-platform-terraform-module-template)](https://operations-engineering-reports.cloud-platform.service.justice.gov.uk/public-github-repositories.html#modernisation-platform-terraform-module-template "Link to report")

## Usage

```hcl

module "lambda" {
  source                         = "github.com/ministryofjustice/modernisation-platform-terraform-lambda-function"
  application_name               = local.application_name
  tags                           = local.tags
  description                    = "lambda description"
  role_name                      = local.lambda_role_name
  policy_json                    = data.aws_iam_policy_document.lambda_policy.json
  function_name                  = local.lambda_function_name
  create_role                    = true
  reserved_concurrent_executions = 1
  environment_variables = {
    "key1" = "value1"
  }
  image_uri    = local.ecr_image_uri
  timeout      = 600
  tracing_mode = "Active"

  allowed_triggers = {
    AllowStopExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.lambda_cloudwatch_schedule_morning.arn
    }
    AllowStartExecutionFromCloudWatch = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.lambda_cloudwatch_schedule_evening.arn
    }
  }

}

```
<!--- BEGIN_TF_DOCS --->
<!--- END_TF_DOCS --->

## Looking for issues?
If you're looking to raise an issue with this module, please create a new issue in the [Modernisation Platform repository](https://github.com/ministryofjustice/modernisation-platform/issues).

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
