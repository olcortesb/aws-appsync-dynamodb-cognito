output "appsync_graphql_url" {
  description = "AppSync GraphQL endpoint URL"
  value       = aws_appsync_graphql_api.this.uris["GRAPHQL"]
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.this.id
}

output "cognito_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.this.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.this.name
}

output "cognito_hosted_ui_url" {
  description = "Cognito Hosted UI login URL"
  value       = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${var.aws_region}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.this.id}&response_type=code&scope=email+openid+profile&redirect_uri=${var.cognito_callback_url}"
}
