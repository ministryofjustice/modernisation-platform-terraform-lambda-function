data "aws_iam_policy_document" "assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
  dynamic "statement" {
    for_each = length(var.additional_trust_roles) > 0 ? var.additional_trust_roles : []
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = [statement.value]
      }
    }
  }

}
data "aws_iam_policy_document" "combined-assume-role-policy" {
  count                   = var.create_role ? 1 : 0
  source_policy_documents = concat([data.aws_iam_policy_document.assume_role[0].json], var.additional_trust_statements)
}

resource "aws_iam_role" "this" {
  count              = var.create_role ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.combined-assume-role-policy[0].json
  name               = coalesce(var.role_name, var.function_name)
  tags               = var.tags
}

resource "aws_iam_policy" "policy_from_json" {
  count  = var.create_role && var.policy_json_attached ? 1 : 0
  name   = coalesce(var.policy_name, var.role_name, var.function_name)
  policy = var.policy_json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "policy_from_json" {
  count      = var.create_role && var.policy_json_attached ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.policy_from_json[0].arn
}

resource "aws_iam_role_policy_attachment" "policy_arns" {
  count = var.create_role && length(var.policy_arns) > 0 ? length(var.policy_arns) : 0

  role       = aws_iam_role.this[0].name
  policy_arn = var.policy_arns[count.index]
}

resource "aws_lambda_function" "this" { #tfsec:ignore:aws-lambda-enable-tracing
  #checkov:skip=CKV_AWS_116
  #checkov:skip=CKV_AWS_117
  #checkov:skip=CKV_AWS_272 "Code signing not required"
  #checkov:skip=CKV_AWS_173 "These lambda envvars aren't sensitive and don't need a cmk. Default AWS KMS key is sufficient"
  function_name                  = var.function_name
  description                    = var.description
  reserved_concurrent_executions = var.reserved_concurrent_executions
  image_uri                      = var.image_uri
  filename                       = var.filename
  source_code_hash               = var.source_code_hash
  package_type                   = var.package_type
  role                           = var.create_role ? aws_iam_role.this[0].arn : var.lambda_role
  timeout                        = var.timeout
  memory_size                    = var.memory_size

  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }
  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }
  dynamic "vpc_config" {
    for_each = var.subnet_ids != null && var.security_group_ids != null ? [true] : []
    content {
      security_group_ids = var.security_group_ids
      subnet_ids         = var.subnet_ids
    }
  }
}

resource "aws_lambda_permission" "allowed_triggers" {
  for_each = { for k, v in var.allowed_triggers : k => v }

  function_name = aws_lambda_function.this.function_name

  statement_id = each.key
  action       = try(each.value.action, "lambda:InvokeFunction")
  principal    = try(each.value.principal, format("%s.amazonaws.com", try(each.value.service, "")))
  source_arn   = try(each.value.source_arn, null)
}

resource "aws_lambda_function_event_invoke_config" "this" {
  count         = var.sns_topic_on_success == "" && var.sns_topic_on_failure == "" ? 0 : 1
  function_name = aws_lambda_function.this.function_name

  destination_config {
    dynamic "on_failure" {
      for_each = var.sns_topic_on_failure != "" ? [1] : []
      content {
        destination = var.sns_topic_on_failure
      }
    }
    dynamic "on_success" {
      for_each = var.sns_topic_on_success != "" ? [1] : []
      content {
        destination = var.sns_topic_on_success
      }
    }
  }
}
