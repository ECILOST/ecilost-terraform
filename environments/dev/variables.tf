variable "subscription_id" {
  type    = string
  default = "fbca1ee8-a472-4800-b62b-f8e36adfaa58"
}

variable "resource_group_name" {
  type    = string
  default = "rg-EciLost"
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "storage_account_name" {
  type    = string
  default = "stecilost"
}

variable "log_analytics_workspace_name" {
  type    = string
  default = "DefaultWorkspace-fbca1ee8-a472-4800-b62b-f8e36adfaa58-CCAN"
}

variable "log_analytics_workspace_resource_group" {
  type    = string
  default = "DefaultResourceGroup-CCAN"
}

variable "min_replicas" {
  description = "Sobrescribe el valor por defecto del ambiente (null = usar el de locals)."
  type        = number
  default     = null
}

# --- Valores en secrets.auto.tfvars (no versionado); ver secrets.example.tfvars ---------

variable "frontend_url" {
  type = string
}

variable "google_client_id" {
  type = string
}

variable "google_client_secret" {
  type      = string
  sensitive = true
}

variable "staff_emails" {
  type    = string
  default = ""
}

variable "rabbitmq_url" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
  default = {
    project    = "ecilost"
    managed-by = "terraform"
  }
}

variable "database_url" {
  description = "Connection string DIRECTA (sin -pooler) del proyecto Neon de este ambiente."
  type        = string
  sensitive   = true
}
