variable "subscription_id" {
  description = "Suscripcion Azure for Students que contiene rg-EciLost."
  type        = string
  default     = "fbca1ee8-a472-4800-b62b-f8e36adfaa58"
}

variable "resource_group_name" {
  description = "Resource group existente. No se crea aqui."
  type        = string
  default     = "rg-EciLost"
}

variable "location" {
  description = "Region de los recursos. PostgreSQL Flexible no se puede aprovisionar en eastus con esta suscripcion."
  type        = string
  default     = "canadacentral"
}

variable "storage_account_name" {
  description = "Nombre global y unico de la cuenta de almacenamiento."
  type        = string
  default     = "stecilost"
}

variable "tags" {
  type = map(string)
  default = {
    project    = "ecilost"
    managed-by = "terraform"
  }
}
