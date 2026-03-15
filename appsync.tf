# --- AppSync GraphQL API ---
resource "aws_appsync_graphql_api" "this" {
  name                = "${local.prefix}-api"
  authentication_type = "AMAZON_COGNITO_USER_POOLS"

  user_pool_config {
    aws_region     = var.aws_region
    default_action = "ALLOW"
    user_pool_id   = aws_cognito_user_pool.this.id
  }

  schema = <<-SCHEMA
    type Item {
      id: ID!
      title: String!
      content: String
      createdAt: String
    }

    input CreateItemInput {
      title: String!
      content: String
    }

    type Query {
      getItem(id: ID!): Item
      listItems: [Item]
    }

    type Mutation {
      createItem(input: CreateItemInput!): Item
    }

    schema {
      query: Query
      mutation: Mutation
    }
  SCHEMA
}

# --- IAM Role for AppSync -> DynamoDB ---
resource "aws_iam_role" "appsync_dynamodb" {
  name = "${local.prefix}-appsync-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "appsync.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "appsync_dynamodb" {
  name = "${local.prefix}-appsync-dynamodb-policy"
  role = aws_iam_role.appsync_dynamodb.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Scan",
      ]
      Resource = aws_dynamodb_table.this.arn
    }]
  })
}

# --- DataSource ---
resource "aws_appsync_datasource" "dynamodb" {
  api_id           = aws_appsync_graphql_api.this.id
  name             = "ItemsTable"
  type             = "AMAZON_DYNAMODB"
  service_role_arn = aws_iam_role.appsync_dynamodb.arn

  dynamodb_config {
    table_name = aws_dynamodb_table.this.name
    region     = var.aws_region
  }
}

# --- Resolvers ---

# createItem
resource "aws_appsync_resolver" "create_item" {
  api_id      = aws_appsync_graphql_api.this.id
  type        = "Mutation"
  field       = "createItem"
  data_source = aws_appsync_datasource.dynamodb.name

  request_template = <<-VTL
    {
      "version": "2018-05-29",
      "operation": "PutItem",
      "key": {
        "id": $util.dynamodb.toDynamoDBJson($util.autoId())
      },
      "attributeValues": {
        "title":     $util.dynamodb.toDynamoDBJson($ctx.args.input.title),
        "content":   $util.dynamodb.toDynamoDBJson($ctx.args.input.content),
        "createdAt": $util.dynamodb.toDynamoDBJson($util.time.nowISO8601())
      }
    }
  VTL

  response_template = "$util.toJson($ctx.result)"
}

# getItem
resource "aws_appsync_resolver" "get_item" {
  api_id      = aws_appsync_graphql_api.this.id
  type        = "Query"
  field       = "getItem"
  data_source = aws_appsync_datasource.dynamodb.name

  request_template = <<-VTL
    {
      "version": "2018-05-29",
      "operation": "GetItem",
      "key": {
        "id": $util.dynamodb.toDynamoDBJson($ctx.args.id)
      }
    }
  VTL

  response_template = "$util.toJson($ctx.result)"
}

# listItems
resource "aws_appsync_resolver" "list_items" {
  api_id      = aws_appsync_graphql_api.this.id
  type        = "Query"
  field       = "listItems"
  data_source = aws_appsync_datasource.dynamodb.name

  request_template = <<-VTL
    {
      "version": "2018-05-29",
      "operation": "Scan"
    }
  VTL

  response_template = "$util.toJson($ctx.result.items)"
}
