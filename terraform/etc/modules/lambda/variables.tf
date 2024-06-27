variable "lambda_functions" {
  description = "Map of Lambda functions to create"
  type = map(object({
    handler     = string
    runtime     = string
    environment = map(string)
    memory_size = number
    s3_key      = string
  }))
}

variable "s3_bucket" {
  description = "The S3 bucket containing the Lambda function code"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "om_frontend_endpoint" {
  description = "OM Frontend Endpoint"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "IAM role ARN for Lambda execution"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "api_gateway_id" {
  description = "API Gateway ID"
  type        = string
}
