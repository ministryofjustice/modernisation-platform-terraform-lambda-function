variable "create_role" {
  description = "Controls whether IAM role for Lambda Function should be created"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Name of IAM role to use for Lambda Function"
  type        = string
  default     = null
}

variable "role_description" {
  description = "Description of IAM role to use for Lambda Function"
  type        = string
  default     = null
}

variable "additional_trust_roles" {
  description = "ARN of other roles to be passed as principals for sts:AssumeRole"
  default     = []
  type        = list(string)
}

variable "additional_trust_statements" {
  description = "Json attributes of additional iam policy documents to add to the trust policy"
  default     = []
  type        = list(string)
}

variable "policy_name" {
  description = "IAM policy name. It override the default value, which is the same as role_name"
  type        = string
  default     = null
}
variable "policy_json" {
  description = "An policy document as JSON to attach to the Lambda Function role"
  type        = string
  default     = null
}

variable "policy_arns" {
  description = "List of policy statements ARN to attach to Lambda Function role"
  type        = list(string)
  default     = []
}

variable "function_name" {
  description = "A unique name for your Lambda Function"
  type        = string
  default     = ""
}

variable "lambda_role" {
  description = " IAM role ARN attached to the Lambda Function. This governs both who / what can invoke your Lambda Function, as well as what resources our Lambda Function has access to. See Lambda Permission Model for more details."
  type        = string
  default     = ""
}

variable "description" {
  description = "Description of your Lambda Function (or Layer)"
  type        = string
  default     = ""
}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this Lambda Function. A value of 0 disables Lambda Function from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1."
  type        = number
  default     = -1
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "package_type" {
  description = "The Lambda deployment package type. Valid options: Image or Zip"
  type        = string
  default     = "Image"
}

variable "image_uri" {
  description = "The ECR image URI containing the function's deployment package."
  type        = string
  default     = null
}

variable "filename" {
  description = "The absolute path to an existing zip-file to use"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Hash value of the archive file. Calculated externally. Use to trigger updates when source file is changed."
  type        = string
  default     = null
}

variable "handler" {
  description = "Lambda Function entrypoint in your code"
  type        = string
  default     = null
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = null
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  type        = number
  default     = 3
}

variable "tracing_mode" {
  description = "Tracing mode of the Lambda Function. Valid value can be either PassThrough or Active."
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Common tags to be used by all resources"
}

variable "application_name" {
  type        = string
  description = "Name of application"
}

variable "allowed_triggers" {
  description = "Map of allowed triggers to create Lambda permissions"
  type        = map(any)
  default     = {}
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
}

variable "policy_json_attached" {
  description = "A json policy document is being passed into the module"
  type        = bool
  default     = false
}

variable "sns_topic_on_failure" {
  description = "SNS topic arn for the lambda's destination on failure."
  type        = string
  default     = ""
}

variable "sns_topic_on_success" {
  description = "SNS topic arn for the lambda's destination on success."
  type        = string
  default     = ""
}

variable "vpc_subnet_ids" {
  description = "List of subnet ids when Lambda Function should run in the VPC. Usually private or intra subnets."
  type        = list(string)
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group ids when Lambda Function should run in the VPC."
  type        = list(string)
  default     = null
}
