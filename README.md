# Ticketing RabbitMQ

Shared RabbitMQ instance used by the Ticketing microservices.

It can be run on its own or, more commonly, as part of a combined environment started from the `configuration` repository.

## Requirements

- Docker
- Docker Compose v2

## Repository Structure

```text
rabbitMQ/
│
├── definitions/
│   └── definitions.json.template
├── scripts/
│   ├── deploy.bat
│   └── deploy.sh
├── .env.example
├── .gitattributes
├── .gitignore
├── docker-compose.yml
├── entrypoint.sh
├── rabbitmq.conf
└── README.md
```

- **`docker-compose.yml`**: RabbitMQ service (`rabbitmq:4-management`) with a persistent volume.
- **`entrypoint.sh`**: Generates `definitions.json` from the template at startup, then starts RabbitMQ.
- **`rabbitmq.conf`**: RabbitMQ configuration, mounted read-only.
- **`definitions/definitions.json.template`**: Template of the broker definitions (users, vhosts, exchanges, queues, bindings).
- **`scripts/`**: Deployment scripts: `deploy.bat` for Windows and `deploy.sh` for Linux and macOS.
- **`.gitattributes`**: Forces LF line endings (see [Line endings](#line-endings)).

## Configuration

Create a `.env` file from `.env.example` and configure:

- RabbitMQ username and password (`RABBITMQ_DEFAULT_USER`, `RABBITMQ_DEFAULT_PASS`).
- AMQP port (`RABBITMQ_AMQP_PORT`).
- Management UI port (`RABBITMQ_MANAGEMENT_PORT`).

When RabbitMQ is started from the `configuration` repository, these variables are read from `configuration/env_files/.env` instead.

## Deployment

### Standalone

**Windows:**

```bat
scripts\deploy.bat local
scripts\deploy.bat down
```

**Linux / macOS:**

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh local
./scripts/deploy.sh down
```

- `local` starts RabbitMQ locally.
- `down` stops RabbitMQ and removes its volumes.

**Warning:** The `down` command deletes all persistent RabbitMQ data.

### Together with other services

Use the setup script of the `configuration` repository, which includes this Compose file in combined environments (for example `sales_rabbitmq`) and handles cloning, start and stop.

## Broker definitions

At startup, `entrypoint.sh`:

1. Checks that `RABBITMQ_USER` and `RABBITMQ_PASSWORD` are set.
2. Replaces the `${RABBITMQ_USER}` and `${RABBITMQ_PASSWORD}` placeholders in `definitions/definitions.json.template`.
3. Writes the result to `definitions/definitions.json`, which RabbitMQ loads.
4. Starts RabbitMQ.

The default definitions create:

| Type | Name | Notes |
|---|---|---|
| User | `${RABBITMQ_USER}` | `administrator` tag, full permissions on vhost `/` |
| Exchange | `payments-events` | `direct`, durable |
| Queue | `sales.payments-events` | durable |
| Binding | `payments-events` → `sales.payments-events` | routing key `#` |

To add queues, exchanges or bindings, edit `definitions/definitions.json.template`. Do not edit the generated `definitions.json`: it is overwritten at every start.

Definitions are imported when the broker starts, so after changing the template recreate the container:

```bash
docker compose up -d --force-recreate
```

## Management UI

Once started, the RabbitMQ Management UI is available at:

`http://localhost:15672`

Use the credentials configured in `.env`. If you changed `RABBITMQ_MANAGEMENT_PORT`, use that port instead.

## Line endings

`entrypoint.sh` and the other mounted files must use **LF** line endings. With CRLF, the container shell reads `set -e\r` and fails with `Illegal option -`.

The `.gitattributes` file in this repository forces LF, so the problem does not occur even on Windows with `core.autocrlf=true`:

```text
* text=auto
*.sh       text eol=lf
*.conf     text eol=lf
*.template text eol=lf
*.json     text eol=lf
*.yaml     text eol=lf
*.yml      text eol=lf
```

Do not remove it. To verify a clone, run `git ls-files --eol`: the `w/` column must be `w/lf` for `entrypoint.sh`, `rabbitmq.conf`, the template and the scripts in `scripts/`.

## Troubleshooting

| Problem | Cause and fix |
|---|---|
| `Illegal option -` at container start | `entrypoint.sh` has CRLF line endings. See [Line endings](#line-endings). |
| `RABBITMQ_USER non impostata` | `RABBITMQ_DEFAULT_USER` is missing in `.env`. |
| `definitions.json is a directory` | A mounted path was missing on the host and Docker created a directory. Remove it and restart. |
| Changes to the template have no effect | Recreate the container with `docker compose up -d --force-recreate`. |
| Old users or queues still present | Data lives in the `rabbitmq_data` volume. Run the `down` command to delete it. |
| `deploy.sh` fails with `bash\r` or `$'\r'` errors | The script has CRLF line endings. Run `sed -i 's/\r$//' scripts/deploy.sh` (on macOS: `sed -i '' 's/\r$//' scripts/deploy.sh`). |