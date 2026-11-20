# Ticketing RabbitMQ

Shared RabbitMQ instance used by the Ticketing microservices.

## Requirements

- Docker
- Docker Compose

## Configuration

Create a `.env` file from `.env.example` and configure:

- RabbitMQ username and password.
- AMQP port.
- Management UI port.

## Deployment

Start RabbitMQ locally:

```bat
deploy.bat local
```

Stop RabbitMQ and remove its volumes:

```bat
deploy.bat down
```

**Warning:** The `down` command deletes all persistent RabbitMQ data.

## Management UI

Once started, the RabbitMQ Management UI is available at:

`http://localhost:15672`

Use the credentials configured in `.env`.