output "rest_api_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "root_resource_id" {
  description = "The root resource ID of the API Gateway"
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "get_list_resource_id" {
  description = "The resource ID for /get-list"
  value       = aws_api_gateway_resource.get_list.id
}

output "get_server_resource_id" {
  description = "The resource ID for /get-server"
  value       = aws_api_gateway_resource.get_server.id
}

output "get_server_from_list_resource_id" {
  description = "The resource ID for /get-server/from-list"
  value       = aws_api_gateway_resource.get_server_from_list.id
}

output "set_list_resource_id" {
  description = "The resource ID for /set-list"
  value       = aws_api_gateway_resource.set_list.id
}
