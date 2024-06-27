variable "api_name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "The description of the API Gateway"
  type        = string
  default     = ""
}

variable "lambda_invoke_arns" {
  description = "Map of Lambda function invoke ARNs"
  type        = map(string)
}
