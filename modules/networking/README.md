# Networking

Sin recursos por ahora. Container Apps Consumption sin VNet propia no tiene costo de red, y
ningun servicio necesita ingress TCP (RabbitMQ esta en CloudAMQP). PostgreSQL usa acceso
publico con firewall (ver `modules/databases`). Revisar si se exige conectividad privada.
