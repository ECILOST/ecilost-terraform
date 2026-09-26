# Messaging

Sin recursos Azure. RabbitMQ lo provee **CloudAMQP** (plan gratuito, `ca-central-1`), fuera de Azure:
Azure Service Bus habla AMQP 1.0 y los servicios usan `amqplib` (AMQP 0-9-1).

Cada ambiente usa su **propia instancia** CloudAMQP: las colas tienen nombres fijos
(`ecilost.wallet.bid-holds`, `engagement.events.v1`, ...) y compartir vhost haria que los
consumidores de dev se quedaran con eventos de prod. La URL entra como secreto
(`rabbitmq_url`) en `environments/<env>/secrets.auto.tfvars`.
