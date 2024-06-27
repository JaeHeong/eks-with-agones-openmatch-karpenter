variable "lambda_functions" {
  description = "Map of Lambda functions to create"
  type = map(object({
    handler     = string
    runtime     = string
    role        = string
    environment = map(string)
    memory_size = number
    timeout     = number
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
