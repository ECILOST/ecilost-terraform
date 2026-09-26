# Identidad administrada de un ambiente y su acceso minimo a Blob Storage.
#
# catalog-service usa DefaultAzureCredential (AZURE_CLIENT_ID) para subir/borrar blobs y
# firma las URLs de lectura con una user delegation key. Por eso necesita:
#   - Storage Blob Data Contributor solo sobre SU contenedor (dev no ve el de prod), y
#   - Storage Blob Delegator sobre la cuenta, que solo permite pedir la delegation key
#     (la accion existe a nivel de cuenta y no se puede acotar al contenedor).

resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "blob_container" {
  scope                = var.storage_container_scope
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "blob_delegator" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Delegator"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  principal_type       = "ServicePrincipal"
}
