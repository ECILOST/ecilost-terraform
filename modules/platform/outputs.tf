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

