provider "aws" {
  region = "ap-northeast-2"
}

module "lambda" {
  source = "./modules/lambda"

  s3_bucket            = "test-lambda-kjh"
  table_name           = aws_dynamodb_table.server_list.name
  om_frontend_endpoint = "a405f901866348e8e.awsglobalaccelerator.com:50504"

  lambda_functions = {
    get_list = {
      handler     = "lambda_function.lambda_handler"
      runtime     = "python3.9"
      role        = "arn:aws:iam::058264399880:role/service-role/get_list-role-14o0s0kr"
      environment = {}
      memory_size = 128
      timeout     = 30
      s3_key      = "get_list.zip"
    }
    get_server = {
      handler     = "bootstrap"
      runtime     = "provided.al2023"
      role        = "arn:aws:iam::058264399880:role/service-role/get_server-role-q5ocpdnk"
      environment = {}
      memory_size = 128
      timeout     = 30
      s3_key      = "get_server.zip"
    }
    get_server_from_list = {
      handler     = "lambda_function.lambda_handler"
      runtime     = "python3.9"
      role        = "arn:aws:iam::058264399880:role/service-role/get_server_from_list-role-p7r8pl1y"
      environment = {}
      memory_size = 128
      timeout     = 30
      s3_key      = "get_server_from_list.zip"
    }
    set_list = {
      handler     = "lambda_function.lambda_handler"
      runtime     = "python3.9"
      role        = "arn:aws:iam::058264399880:role/service-role/set_list-role-754obidz"
      environment = {}
      memory_size = 128
      timeout     = 30
      s3_key      = "set_list.zip"
    }
  }
}

module "api_gateway" {
  source = "./modules/api_gateway"

  api_name           = "manager"
  api_description    = ""
  lambda_invoke_arns = module.lambda.lambda_invoke_arns
}

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
