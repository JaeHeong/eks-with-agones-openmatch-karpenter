data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "this" {
  for_each      = var.lambda_functions
  function_name = each.key
  handler       = each.value.handler
  runtime       = each.value.runtime
  role          = var.lambda_execution_role_arn
  environment {
    variables = merge(each.value.environment, {
      TABLE_NAME           = var.table_name,
      OM_FRONTEND_ENDPOINT = var.om_frontend_endpoint
    })
  }
  memory_size = each.value.memory_size
  timeout     = 30
  s3_bucket   = var.s3_bucket
  s3_key      = each.value.s3_key
}

resource "aws_lambda_permission" "apigw" {
  for_each = var.lambda_functions

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.api_gateway_id}/*/*"
}

output "lambda_arns" {
  value = { for name, func in aws_lambda_function.this : name => func.arn }
}

output "lambda_invoke_arns" {
  value = { for name, func in aws_lambda_function.this : name => func.invoke_arn }
}
