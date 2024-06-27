provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_dynamodb_table" "server_list" {
  name         = "server_list"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Room"

  attribute {
    name = "Room"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }

  ttl {
    attribute_name = ""
    enabled        = false
  }

  tags = {
    Name = "server_list"
  }
}

module "iam" {
  source = "./modules/iam"
}

module "api_gateway" {
  source = "./modules/api_gateway"

  api_name           = "manager"
  api_description    = ""
  lambda_invoke_arns = module.lambda.lambda_invoke_arns
}

module "lambda" {
  source = "./modules/lambda"

  s3_bucket                 = "test-lambda-kjh-2"
  table_name                = aws_dynamodb_table.server_list.name
  om_frontend_endpoint      = "a405f901866348e8e.awsglobalaccelerator.com:50504"
  lambda_execution_role_arn = module.iam.lambda_execution_role_arn
  region                    = var.region
  api_gateway_id            = module.api_gateway.api_id

  lambda_functions = {
    get_list = {
      handler     = "lambda_function.lambda_handler"
      runtime     = "python3.9"
      environment = {}
      memory_size = 128
      s3_key      = "get_list.zip"
    }
    get_server = {
      handler     = "bootstrap"
      runtime     = "provided.al2023"
      environment = {}
      memory_size = 128
      s3_key      = "get_server.zip"
    }
    get_server_from_list = {
      handler     = "lambda_function.lambda_handler"
      runtime     = "python3.9"
      environment = {}
      memory_size = 128
      s3_key      = "get_server_from_list.zip"
    }
    set_list = {
      handler     = "lambda_function.lambda_handler"
      runtime     = "python3.9"
      environment = {}
      memory_size = 128
      s3_key      = "set_list.zip"
    }
  }
}

# resource "null_resource" "put_dynamodb_policy" {
#   provisioner "local-exec" {
#     command = <<EOT
# aws dynamodb put-resource-policy --resource-arn ${aws_dynamodb_table.server_list.arn} --policy "{\\"Version\\": \\"2012-10-17\\", \\"Statement\\": [{\\"Effect\\": \\"Allow\\", \\"Principal\\": {\\"AWS\\": \\"${module.iam.lambda_execution_role_arn}\\"}, \\"Action\\": \\"dynamodb:*\\" , \\"Resource\\": \\"${aws_dynamodb_table.server_list.arn}\\"}]}"
#     EOT
#   }
# }

output "api_id" {
  value = module.api_gateway.api_id
}
