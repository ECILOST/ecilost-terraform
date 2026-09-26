# Un ambiente completo de ECI Lost: Container Apps Environment, identidad, contenedor de
# multimedia y los cinco microservicios. dev y prod llaman a este modulo con distintos
# valores. PostgreSQL es externo (Neon, un proyecto por ambiente): aqui solo llega su URL.
#
# Lo que se configura aqui sale de los .env.example, Dockerfile y src/config/* de cada
# repositorio en su rama develop.

locals {
  prefix = "ecilost"
  tags   = merge(var.tags, { environment = var.environment })

  jwks_url = "${module.auth.url}/.well-known/jwks.json"

  # auth-service firma los tokens; los demas los verifican con estos dos valores exactos.
  jwt_issuer   = "https://auth.ecilost.${var.environment}"
  jwt_audience = "ecilost-services"

  # Una base por ambiente y un schema por servicio: el `?schema=` de DATABASE_URL es como
  # cada servicio ya aisla sus tablas (y como Prisma sabe donde migrar).
  database_url = {
    for schema in ["auth", "catalog", "wallet", "auction", "public"] :
    schema => "${var.database_url}${strcontains(var.database_url, "?") ? "&" : "?sslmode=require&"}schema=${schema}"
  }

  prisma_migrate = ["npx", "prisma", "migrate", "deploy"]

  image = { for svc in ["auth", "catalog", "wallet", "auction", "engagement"] :
    svc => "${var.image_registry}/ecilost-${svc}-service:${var.image_tag}"
  }
}

# --- Plataforma -----------------------------------------------------------------------

resource "azurerm_container_app_environment" "this" {
  name                       = "cae-${local.prefix}-${var.environment}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = local.tags
}

resource "azurerm_storage_container" "media" {
  name                  = "catalog-media-${var.environment}"
  storage_account_id    = var.storage_account_id
  container_access_type = "private"
}

module "identity" {
  source = "../security"

  name                    = "id-${local.prefix}-${var.environment}"
  resource_group_name     = var.resource_group_name
  location                = var.location
  storage_account_id      = var.storage_account_id
  storage_container_scope = "${var.storage_account_id}/blobServices/default/containers/${azurerm_storage_container.media.name}"
  tags                    = local.tags
}

# --- Secretos generados ------------------------------------------------------------------

resource "tls_private_key" "jwt" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "random_password" "cookie" {
  length  = 48
  special = false
}

# --- Microservicios ----------------------------------------------------------------------

module "auth" {
  source = "../compute"

  name                         = "${local.prefix}-auth-${var.environment}"
  container_name               = "auth"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  container_app_environment_id = azurerm_container_app_environment.this.id
  identity_id                  = module.identity.id
  image                        = local.image["auth"]
  port                         = 3000
  health_path                  = "/health"
  min_replicas                 = var.min_replicas
  migration_command            = local.prisma_migrate
  tags                         = local.tags

  env = {
    PORT                      = "3000"
    NODE_ENV                  = "production"
    GOOGLE_CLIENT_ID          = var.google_client_id
    GOOGLE_REDIRECT_URI       = "${var.frontend_url}/auth/google/callback"
    STAFF_EMAILS              = var.staff_emails
    JWT_ISSUER                = local.jwt_issuer
    JWT_AUDIENCE              = local.jwt_audience
    JWT_PUBLIC_KEY            = base64encode(tls_private_key.jwt.public_key_pem)
    ACCESS_TOKEN_TTL_SECONDS  = "900"
    REFRESH_TOKEN_TTL_SECONDS = "604800"
    COOKIE_SECURE             = "true"
    POST_LOGIN_REDIRECT_URL   = "${var.frontend_url}/items"
    POST_LOGIN_ERROR_URL      = "${var.frontend_url}/login"
  }

  secret_env = {
    DATABASE_URL         = local.database_url["auth"]
    GOOGLE_CLIENT_SECRET = var.google_client_secret
    JWT_PRIVATE_KEY      = base64encode(tls_private_key.jwt.private_key_pem_pkcs8)
    COOKIE_SECRET        = random_password.cookie.result
    RABBITMQ_URL         = var.rabbitmq_url
  }
}

module "catalog" {
  source = "../compute"

  name                         = "${local.prefix}-catalog-${var.environment}"
  container_name               = "catalog"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  container_app_environment_id = azurerm_container_app_environment.this.id
  identity_id                  = module.identity.id
  image                        = local.image["catalog"]
  port                         = 3001
  health_path                  = "/"
  min_replicas                 = var.min_replicas
  migration_command            = local.prisma_migrate
  tags                         = local.tags

  env = {
    PORT                       = "3001"
    NODE_ENV                   = "production"
    AUTH_JWKS_URL              = local.jwks_url
    JWT_ISSUER                 = local.jwt_issuer
    JWT_AUDIENCE               = local.jwt_audience
    AZURE_STORAGE_ACCOUNT_NAME = var.storage_account_name
    AZURE_STORAGE_ACCOUNT_URL  = trimsuffix(var.storage_blob_endpoint, "/")
    AZURE_STORAGE_CONTAINER    = azurerm_storage_container.media.name
    # DefaultAzureCredential elige la user-assigned identity por este client id.
    AZURE_CLIENT_ID = module.identity.client_id
  }

  secret_env = {
    DATABASE_URL = local.database_url["catalog"]
    RABBITMQ_URL = var.rabbitmq_url
  }
}

module "wallet" {
  source = "../compute"

  name                         = "${local.prefix}-wallet-${var.environment}"
  container_name               = "wallet"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  container_app_environment_id = azurerm_container_app_environment.this.id
  identity_id                  = module.identity.id
  image                        = local.image["wallet"]
  port                         = 3002
  health_path                  = "/wallet/health"
  min_replicas                 = var.min_replicas
  migration_command            = local.prisma_migrate
  tags                         = local.tags

  # wallet usa AUTH_ISSUER/AUTH_AUDIENCE, no JWT_*: mismo valor, otro nombre.
  env = {
    PORT                    = "3002"
    NODE_ENV                = "production"
    AUTH_JWKS_URL           = local.jwks_url
    AUTH_ISSUER             = local.jwt_issuer
    AUTH_AUDIENCE           = local.jwt_audience
    INITIAL_ECICOIN_BALANCE = tostring(var.initial_ecicoin_balance)
  }

  secret_env = {
    DATABASE_URL = local.database_url["wallet"]
    RABBITMQ_URL = var.rabbitmq_url
  }
}

module "auction" {
  source = "../compute"

  name                         = "${local.prefix}-auction-${var.environment}"
  container_name               = "auction"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  container_app_environment_id = azurerm_container_app_environment.this.id
  identity_id                  = module.identity.id
  image                        = local.image["auction"]
  port                         = 3003
  min_replicas                 = var.min_replicas
  migration_command            = local.prisma_migrate
  tags                         = local.tags

  env = {
    PORT          = "3003"
    NODE_ENV      = "production"
    AUTH_JWKS_URL = local.jwks_url
    JWT_ISSUER    = local.jwt_issuer
    JWT_AUDIENCE  = local.jwt_audience
  }

  secret_env = {
    DATABASE_URL = local.database_url["auction"]
    RABBITMQ_URL = var.rabbitmq_url
  }
}

module "engagement" {
  source = "../compute"

  name                         = "${local.prefix}-engagement-${var.environment}"
  container_name               = "engagement"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  container_app_environment_id = azurerm_container_app_environment.this.id
  identity_id                  = module.identity.id
  image                        = local.image["engagement"]
  port                         = 3005
  min_replicas                 = var.min_replicas
  # Socket.IO sin adaptador compartido: una sola replica.
  max_replicas      = 1
  migration_command = local.prisma_migrate
  tags              = local.tags

  env = {
    PORT          = "3005"
    NODE_ENV      = "production"
    AUTH_JWKS_URL = local.jwks_url
    JWT_ISSUER    = local.jwt_issuer
    JWT_AUDIENCE  = local.jwt_audience
  }

  secret_env = {
    DATABASE_URL = local.database_url["public"]
    RABBITMQ_URL = var.rabbitmq_url
  }
}
