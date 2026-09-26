output "name" {
  value = azurerm_container_app.this.name
}

output "fqdn" {
  value = azurerm_container_app.this.ingress[0].fqdn
}

output "url" {
  value = "https://${azurerm_container_app.this.ingress[0].fqdn}"
}

output "migration_job_name" {
  value = one(azurerm_container_app_job.migrate[*].name)
}
