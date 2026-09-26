# Databases

Sin recursos Azure. PostgreSQL lo provee **Neon** (plan gratuito), un proyecto por ambiente
(`ecilost-dev`, `Ecilost`/production), PostgreSQL 17. Un servidor Flexible B1ms en Azure
costaria ~US$17/mes aunque no se use.

La connection string **directa** (sin `-pooler`: `prisma migrate` no funciona detras de
PgBouncer) entra como secreto `database_url` en `environments/<env>/secrets.auto.tfvars`, y
`modules/platform` le anade `?schema=<servicio>` para cada microservicio.
