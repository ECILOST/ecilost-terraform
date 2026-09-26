# Security

User-assigned identity por ambiente con `Storage Blob Data Contributor` solo sobre el
contenedor de multimedia de su ambiente y `Storage Blob Delegator` sobre la cuenta (necesario
para las URLs SAS de lectura con user delegation key). Sin Key Vault: los secretos viven como
secretos de Container Apps, sin costo.
