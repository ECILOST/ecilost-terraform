# Copiar a secrets.auto.tfvars (no se versiona: *.tfvars esta en .gitignore) y rellenar.
# Nunca pegar estos valores en issues, PRs ni chats.

# Dominio del proyecto Vercel de ESTE ambiente, sin barra final.
frontend_url = "https://<proyecto-prod>.vercel.app"

# Google Cloud Console > Credenciales > ID de cliente OAuth 2.0 (Aplicacion web).
# Autorizar alli el redirect URI: <frontend_url>/auth/google/callback
google_client_id     = "xxxxxxxx.apps.googleusercontent.com"
google_client_secret = ""

# Correos con rol STAFF, separados por comas.
staff_emails = ""

# Instancia CloudAMQP EXCLUSIVA de este ambiente (las colas tienen nombres fijos:
# compartir vhost con el otro ambiente mezclaria sus eventos).
rabbitmq_url = "amqps://<usuario>:<password>@<host>/<vhost>"

# Neon > proyecto de este ambiente > Connect, con "Connection pooling" DESACTIVADO.
database_url = "postgresql://<usuario>:<password>@ep-xxxx.<region>.aws.neon.tech/neondb?sslmode=require"
