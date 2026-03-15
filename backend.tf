# --- Backend S3 para estado remoto ---
# Descomenta este bloque para usar S3 como backend.
# Asegúrate de crear el bucket previamente:
#
#   aws s3api create-bucket \
#     --bucket <tu-bucket-tfstate> \
#     --region eu-central-1 \
#     --create-bucket-configuration LocationConstraint=eu-central-1
#
# Nota: Desde Terraform 1.10+ el locking nativo se maneja con S3
# mediante use_lockfile = true (archivo .tflock), sin necesidad
# de una tabla DynamoDB.
# Ref: https://developer.hashicorp.com/terraform/language/backend/s3#use_lockfile

# terraform {
#   backend "s3" {
#     bucket       = "<tu-bucket-tfstate>"
#     key          = "appsync-dynamodb-cognito/terraform.tfstate"
#     region       = "eu-central-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
