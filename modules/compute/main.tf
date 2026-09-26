# Un microservicio en Azure Container Apps (Consumption) y, si tiene migraciones Prisma,
# un Container Apps Job de disparo manual que ejecuta `prisma migrate deploy` con la misma
# imagen. El job solo cobra mientras corre.
#
# La imagen la despliega la CI (`az containerapp update`), no Terraform: por eso se ignora
# en el ciclo de vida. `var.image` solo fija la imagen inicial.

locals {
  # Los nombres de secretos de Container Apps solo admiten minusculas, digitos y '-'.
  secret_names = { for k in nonsensitive(keys(var.secret_env)) : k => lower(replace(k, "_", "-")) }
}

resource "azurerm_container_app" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  dynamic "secret" {
    for_each = local.secret_names
    content {
      name  = secret.value
      value = var.secret_env[secret.key]
    }
  }

  ingress {
    external_enabled = true
    target_port      = var.port
    # "http" (HTTP/1.1) es lo que guarda el modo Express; admite el upgrade a WebSocket
    # que usa Socket.IO en engagement.
    transport                  = "http"
    allow_insecure_connections = false

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_name
      image  = var.image
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.env
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = local.secret_names
        content {
          name        = env.key
          secret_name = env.value
        }
      }

      dynamic "liveness_probe" {
        for_each = var.health_path == null ? [] : [var.health_path]
        content {
          transport               = "HTTP"
          port                    = var.port
          path                    = liveness_probe.value
          initial_delay           = 10
          interval_seconds        = 30
          failure_count_threshold = 3
        }
      }
    }
  }

  lifecycle {
    # La imagen la despliega la CI. El resto lo administra el modo "Express" del
    # environment (sin pesos de trafico, escalado HTTP propio) y Terraform no debe pelearlo.
    ignore_changes = [
      template[0].container[0].image,
      template[0].container[0].liveness_probe,
      template[0].cooldown_period_in_seconds,
      template[0].polling_interval_in_seconds,
      template[0].http_scale_rule,
      ingress[0].traffic_weight,
    ]
  }
}

resource "azurerm_container_app_job" "migrate" {
  count = var.migration_command == null ? 0 : 1

  name                         = "${var.name}-migrate"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  container_app_environment_id = var.container_app_environment_id
  replica_timeout_in_seconds   = 600
  replica_retry_limit          = 0
  tags                         = var.tags

  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }

  secret {
    name  = "database-url"
    value = var.secret_env["DATABASE_URL"]
  }

  template {
    container {
      name    = "migrate"
      image   = var.image
      cpu     = var.cpu
      memory  = var.memory
      command = var.migration_command

      env {
        name        = "DATABASE_URL"
        secret_name = "database-url"
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }
}
