resource "aws_lambda_function" "this" {
  for_each      = var.lambda_functions
  function_name = each.key
  handler       = each.value.handler
  runtime       = each.value.runtime
  role          = each.value.role
  environment {
    variables = merge(each.value.environment, {
      TABLE_NAME           = var.table_name,
      OM_FRONTEND_ENDPOINT = var.om_frontend_endpoint
    })
  }
  memory_size = each.value.memory_size
  timeout     = each.value.timeout
  s3_bucket   = var.s3_bucket
  s3_key      = each.value.s3_key
}

output "lambda_arns" {
  value = { for name, func in aws_lambda_function.this : name => func.arn }
}

output "lambda_invoke_arns" {
  value = { for name, func in aws_lambda_function.this : name => func.invoke_arn }
}
