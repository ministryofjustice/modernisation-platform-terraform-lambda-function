output "function_arn" {
  value = module.module_test.lambda_function_arn
}

output "function_name" {
  value = module.module_test.lambda_function_name
}

output "result_code" {
  value = jsondecode(aws_lambda_invocation.test_invocation.result)["statusCode"]
}

output "security_group_id" {
  value = module.module_test.lambda_function_security_group_id
}

output "subnet_id" {
  value = module.module_test.lambda_function_subnet_id
}