output "function_arn" {
  value = module.module_test.lambda_function_arn
}

output "function_name" {
  value = module.module_test.lambda_function_name
}

output "result_code" {
  value = jsondecode(aws_lambda_invocation.test_invocation.result)["statusCode"]
}