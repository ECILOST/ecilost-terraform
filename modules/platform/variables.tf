variable "environment" {
  description = "dev o prod."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment debe ser dev o prod."
  }
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "storage_blob_endpoint" {
  type = string
}

variable "database_url" {
  description = "Connection string directa del proyecto Neon del ambiente. El modulo le anade ?schema=<servicio>."
  type        = string
  sensitive   = true

  validation {
    condition     = startswith(var.database_url, "postgresql://") && !strcontains(var.database_url, "-pooler") && !strcontains(var.database_url, "schema=")
    error_message = "database_url debe ser postgresql://..., conexion directa (sin -pooler: Prisma migrate no funciona con PgBouncer) y sin ?schema=."
  }
}

variable "image_registry" {
  description = "Registro y organizacion de las imagenes."
  type        = string
  default     = "ghcr.io/ecilost"
}

variable "image_tag" {
  description = "Tag inicial (el de la rama que publica la CI). Despues la CI despliega por sha."
  type        = string
}

variable "min_replicas" {
  description = "0 = bajo demanda (sin costo en reposo, sin consumidores ni schedulers); 1 = siempre encendido."
  type        = number
}

variable "frontend_url" {
  description = "Origen publico del frontend en Vercel para este ambiente, sin barra final."
  type        = string

  validation {
    condition     = can(regex("^https://[^/]+$", var.frontend_url))
    error_message = "frontend_url debe ser https://<host> sin barra final."
  }
}

variable "google_client_id" {
  type = string
}

variable "google_client_secret" {
  type      = string
  sensitive = true
}

variable "staff_emails" {
  description = "Correos que entran con rol STAFF, separados por comas."
  type        = string
  default     = ""
}

variable "rabbitmq_url" {
  description = "URL AMQP de la instancia CloudAMQP de ESTE ambiente."
  type        = string
  sensitive   = true
}

variable "initial_ecicoin_balance" {
  description = "Saldo inicial de una billetera nueva (valor de .env.example de wallet)."
  type        = number
  default     = 10000
}

variable "tags" {
  type    = map(string)
  default = {}
}
