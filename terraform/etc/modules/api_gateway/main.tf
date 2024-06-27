resource "aws_api_gateway_rest_api" "this" {
  name                     = var.api_name
  description              = var.api_description
  api_key_source           = "HEADER"
  minimum_compression_size = ""
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "get_list" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "get-list"
}

resource "aws_api_gateway_resource" "get_server" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "get-server"
}

resource "aws_api_gateway_resource" "get_server_from_list" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.get_server.id
  path_part   = "from-list"
}

resource "aws_api_gateway_resource" "set_list" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "set-list"
}

resource "aws_api_gateway_method" "get_list_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.get_list.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_list_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.get_list.id
  http_method             = aws_api_gateway_method.get_list_get.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.lambda_invoke_arns["get_list"]
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  request_templates = {
    "application/json" = ""
  }
  timeout_milliseconds = 29000
}

resource "aws_api_gateway_method_response" "get_list_get_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_list.id
  http_method = aws_api_gateway_method.get_list_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_list_get_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_list.id
  http_method = aws_api_gateway_method.get_list_get.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.get_list_get,
    aws_api_gateway_method_response.get_list_get_200
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "get_list_options" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.get_list.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "get_list_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_list.id
  http_method = aws_api_gateway_method.get_list_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "get_list_options" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.get_list.id
  http_method          = aws_api_gateway_method.get_list_options.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  timeout_milliseconds = 29000
}

resource "aws_api_gateway_integration_response" "get_list_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_list.id
  http_method = aws_api_gateway_method.get_list_options.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.get_list_options,
    aws_api_gateway_method_response.get_list_options_200
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "get_server_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.get_server.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_server_post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.get_server.id
  http_method             = aws_api_gateway_method.get_server_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.lambda_invoke_arns["get_server"]
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  request_templates = {
    "application/json" = ""
  }
  timeout_milliseconds = 29000
}

resource "aws_api_gateway_method_response" "get_server_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_server.id
  http_method = aws_api_gateway_method.get_server_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_server_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_server.id
  http_method = aws_api_gateway_method.get_server_post.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.get_server_post,
    aws_api_gateway_method_response.get_server_post_200
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "get_server_options" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.get_server.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "get_server_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_server.id
  http_method = aws_api_gateway_method.get_server_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "get_server_options" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.get_server.id
  http_method          = aws_api_gateway_method.get_server_options.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  timeout_milliseconds = 29000
}

resource "aws_api_gateway_integration_response" "get_server_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_server.id
  http_method = aws_api_gateway_method.get_server_options.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.get_server_options,
    aws_api_gateway_method_response.get_server_options_200
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "get_server_from_list_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.get_server_from_list.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_server_from_list_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.get_server_from_list.id
  http_method             = aws_api_gateway_method.get_server_from_list_get.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.lambda_invoke_arns["get_server_from_list"]
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  content_handling        = "CONVERT_TO_TEXT"
  request_templates = {
    "application/json" = "{ \r\n\"room\" : \"$input.params('room')\"\r\n}"
  }
  timeout_milliseconds = 29000
}

resource "aws_api_gateway_method_response" "get_server_from_list_get_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_server_from_list.id
  http_method = aws_api_gateway_method.get_server_from_list_get.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "get_server_from_list_get_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_server_from_list.id
  http_method = aws_api_gateway_method.get_server_from_list_get.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.get_server_from_list_get,
    aws_api_gateway_method_response.get_server_from_list_get_200
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "get_server_from_list_options" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.get_server_from_list.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "get_server_from_list_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_server_from_list.id
  http_method = aws_api_gateway_method.get_server_from_list_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "get_server_from_list_options" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.get_server_from_list.id
  http_method          = aws_api_gateway_method.get_server_from_list_options.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  timeout_milliseconds = 29000
}

resource "aws_api_gateway_integration_response" "get_server_from_list_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.get_server_from_list.id
  http_method = aws_api_gateway_method.get_server_from_list_options.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.get_server_from_list_options,
    aws_api_gateway_method_response.get_server_from_list_options_200
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "set_list_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.set_list.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "set_list_post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.set_list.id
  http_method             = aws_api_gateway_method.set_list_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.lambda_invoke_arns["set_list"]
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  content_handling        = "CONVERT_TO_TEXT"
  request_templates = {
    "application/json" = ""
  }
  timeout_milliseconds = 29000
}

resource "aws_api_gateway_method_response" "set_list_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.set_list.id
  http_method = aws_api_gateway_method.set_list_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "set_list_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.set_list.id
  http_method = aws_api_gateway_method.set_list_post.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.set_list_post,
    aws_api_gateway_method_response.set_list_post_200
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_method" "set_list_options" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.set_list.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "set_list_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.set_list.id
  http_method = aws_api_gateway_method.set_list_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "set_list_options" {
  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = aws_api_gateway_resource.set_list.id
  http_method          = aws_api_gateway_method.set_list_options.http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  timeout_milliseconds = 29000
}

resource "aws_api_gateway_integration_response" "set_list_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.set_list.id
  http_method = aws_api_gateway_method.set_list_options.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.set_list_options,
    aws_api_gateway_method_response.set_list_options_200
  ]

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = ""
  }
}
