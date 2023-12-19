output "function_arn" {
  value = module.module_test.lambda_function_arn
}

output "function_name" {
  value = module.module_test.lambda_function_name
}

output "result_code" {
  value = jsondecode(aws_lambda_invocation.test_invocation.result)["statusCode"]
}

output "security_group_ids" {
  value = module.lambda_function_in_vpc.vpc_security_group_ids
}

output "subnet_ids" {
  value = module.lambda_function_in_vpc.vpc_subnet_ids
}

# output "result_code_vpc" {
#   value = jsondecode(aws_lambda_invocation.test_invocation_vpc.result)["statusCode"]
# }