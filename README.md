# ECILOST Terraform

Esqueleto de infraestructura Azure organizado por módulos y ambientes. No provisiona recursos aún: faltan la suscripción, región, estrategia de red, backend remoto, SKU y políticas de retención.

```text
modules/
  networking/       VNet, subredes y conectividad privada
  compute/          Ejecución de contenedores, por definir
  containers/       Azure Container Registry
  databases/        PostgreSQL administrado, por definir
  messaging/        RabbitMQ administrado u operado, decisión pendiente
  security/         Identidades, Key Vault y RBAC
  observability/    Logs, métricas y alertas
environments/
  dev/ staging/ prod/
```

Cada ambiente tiene su raíz Terraform deliberadamente vacía. Antes de añadir recursos se deben definir el backend remoto, las variables no secretas y la procedencia de secretos. Nunca se almacenan secretos, `*.tfvars` reales ni state en Git.
