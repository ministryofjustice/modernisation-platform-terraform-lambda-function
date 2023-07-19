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
