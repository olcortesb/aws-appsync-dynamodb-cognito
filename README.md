# AppSync + DynamoDB + Cognito (Terraform)

API GraphQL con AWS AppSync que persiste directamente en DynamoDB, autenticada con Cognito User Pools.

## Arquitectura

```
Client → Cognito Auth → AppSync (GraphQL) → DynamoDB
```

## Recursos creados

- **Cognito User Pool + Client** — autenticación de usuarios
- **AppSync GraphQL API** — endpoint GraphQL con auth Cognito
- **DynamoDB Table** — almacenamiento de items (PAY_PER_REQUEST)
- **IAM Role** — permisos AppSync → DynamoDB

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Uso

### 1. Crear usuario en Cognito

```bash
aws cognito-idp sign-up \
  --client-id <cognito_client_id> \
  --username user@example.com \
  --password MyPass123

aws cognito-idp admin-confirm-sign-up \
  --user-pool-id <cognito_user_pool_id> \
  --username user@example.com
```

### 2. Obtener token

```bash
aws cognito-idp initiate-auth \
  --client-id <cognito_client_id> \
  --auth-flow USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=user@example.com,PASSWORD=MyPass123
```

Usa el `IdToken` del response como header `Authorization` en las requests a AppSync.

### 3. Queries GraphQL

**Crear item:**
```graphql
mutation {
  createItem(input: { title: "Mi primer post", content: "Contenido del post" }) {
    id
    title
    content
    createdAt
  }
}
```

**Obtener item por ID:**
```graphql
query {
  getItem(id: "abc-123") {
    id
    title
    content
    createdAt
  }
}
```

**Listar todos:**
```graphql
query {
  listItems {
    id
    title
    content
    createdAt
  }
}
```

## Ejemplo rápido con curl

```bash
# 1. Obtener token
TOKEN=$(aws cognito-idp initiate-auth \
  --client-id <cognito_client_id> \
  --auth-flow USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=user@example.com,PASSWORD=MyPass123 \
  --query 'AuthenticationResult.IdToken' --output text)

# 2. Guardar temperatura
curl -s -X POST <appsync_graphql_url> \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { createItem(input: { title: \"Temperatura\", content: \"23.5°C\" }) { id title content createdAt } }"}'

# 3. Obtener por ID (usar el id del response anterior)
curl -s -X POST <appsync_graphql_url> \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query": "query { getItem(id: \"<id>\") { id title content createdAt } }"}'

# 4. Listar todos los items
curl -s -X POST <appsync_graphql_url> \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query": "query { listItems { id title content createdAt } }"}'
```

## Cleanup

```bash
terraform destroy
```
