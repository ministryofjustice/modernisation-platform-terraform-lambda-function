output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = try(aws_lambda_function.this.arn, "")
}

output "lambda_function_invoke_arn" {
  description = "The invoke ARN of the Lambda Function"
  value       = try(aws_lambda_function.this.invoke_arn, "")
}

output "lambda_function_name" {
  description = "The Name of the Lambda Function"
  value       = try(aws_lambda_function.this.function_name, "")
}

output "vpc_security_group_ids" {
  description = "The VPC security groups the lambda function has been deployed into"
  value       = try(aws_lambda_function.this.vpc_config[0].security_group_ids, "")
}

output "vpc_subnet_ids" {
  description = "The vpc subnet(s) the Lambda function has been deployed into"
  value       = try(aws_lambda_function.this.vpc_config[0].subnet_ids, "")
}
