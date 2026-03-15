# --- Cognito User Pool ---
resource "aws_cognito_user_pool" "this" {
  name = "${local.prefix}-user-pool"

  auto_verified_attributes = ["email"]
  username_attributes       = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }
}

# --- Cognito Domain (Hosted UI) ---
resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${local.prefix}-${random_id.cognito_domain.hex}"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "random_id" "cognito_domain" {
  byte_length = 4
}

# --- Cognito Client ---
resource "aws_cognito_user_pool_client" "this" {
  name         = "${local.prefix}-client"
  user_pool_id = aws_cognito_user_pool.this.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  generate_secret = false

  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = [var.cognito_callback_url]
  logout_urls                          = [var.cognito_logout_url]
}
