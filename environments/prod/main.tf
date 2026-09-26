terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    subscription_id      = "fbca1ee8-a472-4800-b62b-f8e36adfaa58"
    resource_group_name  = "rg-EciLost"
    storage_account_name = "stecilost"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
  }
}

locals {
  environment = "prod"

  # Siempre encendido: los consumidores AMQP y los schedulers de auction deben correr.
  default_min_replicas = 1
  image_tag            = "main"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_storage_account" "shared" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Workspace que ya existia en la suscripcion (canadacentral). Solo se lee.
data "azurerm_log_analytics_workspace" "existing" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group
}

module "platform" {
  source = "../../modules/platform"

  environment                = local.environment
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.existing.id
  storage_account_id         = data.azurerm_storage_account.shared.id
  storage_account_name       = data.azurerm_storage_account.shared.name
  storage_blob_endpoint      = data.azurerm_storage_account.shared.primary_blob_endpoint

  image_tag    = local.image_tag
  min_replicas = coalesce(var.min_replicas, local.default_min_replicas)

  frontend_url         = var.frontend_url
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
  staff_emails         = var.staff_emails
  rabbitmq_url         = var.rabbitmq_url
  database_url         = var.database_url

  tags = var.tags
}
