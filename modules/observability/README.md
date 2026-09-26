# Observability

Sin recursos propios: los Container Apps Environments envian logs al workspace de Log
Analytics que ya existia en la suscripcion (`DefaultWorkspace-...-CCAN`), leido como data
source en `environments/*`. Terraform no lo modifica.
