variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "storage_container_scope" {
  description = "ID ARM del contenedor: <storage_account_id>/blobServices/default/containers/<nombre>."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
