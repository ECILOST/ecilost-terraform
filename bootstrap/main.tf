# Bootstrap: la cuenta de almacenamiento que guarda el state de las demas raices y, en
# contenedores separados, la multimedia de catalog. Se aplica una sola vez con state local
# y despues se migra a su propio blob (ver README.md).

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Primer apply con state local; despues se migro aqui con `terraform init -migrate-state`.
  backend "azurerm" {
    subscription_id      = "fbca1ee8-a472-4800-b62b-f8e36adfaa58"
    resource_group_name  = "rg-EciLost"
    storage_account_name = "stecilost"
    container_name       = "tfstate"
    key                  = "bootstrap.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location

  # LRS y Hot: la redundancia minima. La multimedia se puede volver a subir y el state
  # tiene soft delete; no justifican pagar ZRS/GRS.
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
