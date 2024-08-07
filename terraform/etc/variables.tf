variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "om_frontend_endpoint" {
  description = "Open Match frontend endpoint address"
  type        = string
  default     = "a405f901866348e8e.awsglobalaccelerator.com:50504"
}

variable "s3_bucket" {
  description = "lambda s3 bucket name"
  type        = string
  default     = "test-lambda-kjh"
}

// lambda s3 key
variable "get_list_lambda_s3_key" {
  description = "lambda s3 bucket name"
  type        = string
  default     = "get_list.zip"
}
variable "get_server_lambda_s3_key" {
  description = "lambda s3 bucket name"
  type        = string
  default     = "get_server.zip"
}
variable "get_server_from_list_lambda_s3_key" {
  description = "lambda s3 bucket name"
  type        = string
  default     = "get_server_from_list.zip"
}
variable "set_list_lambda_s3_key" {
  description = "lambda s3 bucket name"
  type        = string
  default     = "set_list.zip"
}
