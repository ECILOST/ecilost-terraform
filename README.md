# ECILOST Terraform

Infraestructura Azure de ECI Lost en `rg-EciLost` (suscripcion Azure for Students
`fbca1ee8-...`), region **canadacentral**: la politica de la suscripcion solo admite cinco
regiones y es la mas cercana a CloudAMQP (`ca-central-1`).

```text
bootstrap/            Storage Account `stecilost` + contenedor `tfstate` (state local -> migrado)
                      (PostgreSQL en Neon, externo: ver modules/databases)
environments/dev      Ambiente dev  (bajo demanda: min_replicas = 0)
environments/prod     Ambiente prod (siempre encendido: min_replicas = 1)
environments/staging  Reservado, sin recursos
modules/
  platform/           Un ambiente completo; dev y prod lo llaman con distintos valores
  compute/            Container App + job de migraciones Prisma
  databases/          Sin recursos: PostgreSQL en Neon
  security/           Identidad administrada + RBAC minimo sobre Blob
  containers/ messaging/ networking/ observability/   Sin recursos (ver cada README)
```

## Que crea cada ambiente

| Recurso | Nombre | Notas |
|---|---|---|
| Container Apps Environment | `cae-ecilost-<env>` | Consumption, logs al workspace existente |
| Container Apps | `ecilost-{auth,catalog,wallet,auction,engagement}-<env>` | 0.25 vCPU / 0.5 GiB, max 1 replica |
| Container Apps Jobs | `ecilost-<svc>-<env>-migrate` | Manuales, `npx prisma migrate deploy` |
| User-assigned identity | `id-ecilost-<env>` | Blob Data Contributor solo en su contenedor |
| Blob container | `catalog-media-<env>` | Privado, lectura por SAS |
| Base PostgreSQL | proyecto Neon del ambiente | Un schema por servicio (`?schema=`) |

No se crean: ACR (se usa GHCR), Key Vault (secretos de Container Apps), VNet, gateways,
Front Door, RabbitMQ (CloudAMQP) ni PostgreSQL (Neon) en Azure: ambos externos, uno por ambiente.

## Secretos

Nunca en Git. Cada raiz lee los suyos de `*.auto.tfvars` (ignorado por `.gitignore`); ver los
`*.example.tfvars`. Terraform genera por ambiente el par
RS256 de los JWT y `COOKIE_SECRET`. Quedan en el state, que vive en un blob privado.

## Orden de ejecucion

```bash
# 1. Bootstrap (una sola vez)
cd bootstrap && terraform init && terraform apply
#    luego descomentar el bloque backend de bootstrap/main.tf y:
terraform init -migrate-state

# 2. Ambientes (requiere imagenes publicadas en ghcr.io/ecilost con tag develop / main)
cd ../environments/dev && cp secrets.example.tfvars secrets.auto.tfvars   # rellenar
terraform init && terraform apply

# 3. Migraciones de cada servicio
az containerapp job start -g rg-EciLost -n ecilost-auth-dev-migrate
```

Para una prueba completa en dev (consumidores AMQP y schedulers activos):
`terraform apply -var min_replicas=1`; al terminar, `terraform apply` para volver a 0.
