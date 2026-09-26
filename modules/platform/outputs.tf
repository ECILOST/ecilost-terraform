output "container_app_environment_name" {
  value = azurerm_container_app_environment.this.name
}

output "service_urls" {
  description = "Destinos de los rewrites de Vercel."
  value = {
    auth       = module.auth.url
    catalog    = module.catalog.url
    wallet     = module.wallet.url
    auction    = module.auction.url
    engagement = module.engagement.url
  }
}

output "migration_jobs" {
  value = {
    auth       = module.auth.migration_job_name
    catalog    = module.catalog.migration_job_name
    wallet     = module.wallet.migration_job_name
    auction    = module.auction.migration_job_name
    engagement = module.engagement.migration_job_name
  }
}

output "container_app_names" {
  value = {
    auth       = module.auth.name
    catalog    = module.catalog.name
    wallet     = module.wallet.name
    auction    = module.auction.name
    engagement = module.engagement.name
  }
}

output "identity_client_id" {
  value = module.identity.client_id
}

