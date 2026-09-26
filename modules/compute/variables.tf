variable "name" {
  description = "Nombre de la Container App (<= 32 caracteres, minusculas y guiones)."
  type        = string
}

variable "container_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "container_app_environment_id" {
  type = string
}

variable "identity_id" {
  description = "User-assigned identity del ambiente."
  type        = string
}

variable "image" {
  description = "Imagen inicial. Despues la actualiza la CI."
  type        = string
}

variable "port" {
  description = "Puerto que escucha el proceso (EXPOSE del Dockerfile)."
  type        = number
}

variable "health_path" {
  description = "Ruta HTTP de liveness. null deja las sondas TCP por defecto de Container Apps."
  type        = string
  default     = null
}

variable "env" {
  description = "Variables de entorno no secretas."
  type        = map(string)
  default     = {}
}

variable "secret_env" {
  description = "Variables de entorno secretas; se guardan como secretos de Container Apps."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "min_replicas" {
  description = "0 permite escalar a cero (sin costo en reposo), pero los consumidores AMQP y los schedulers no corren."
  type        = number
}

variable "max_replicas" {
  type    = number
  default = 1
}

variable "cpu" {
  type    = number
  default = 0.25
}

variable "memory" {
  type    = string
  default = "0.5Gi"
}

variable "migration_command" {
  description = "Comando del job de migraciones. null no crea el job."
  type        = list(string)
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
