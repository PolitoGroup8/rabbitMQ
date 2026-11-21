#!/usr/bin/env bash
# ------------------------------------------------------------
# Deploy script for RabbitMQ (Unix/macOS/Linux)
# Supports only "local" (up) and "down" modes, matching the batch version.
# ------------------------------------------------------------

set -euo pipefail   # abort on error, treat unset vars as errors

# ------------------------------
# 1️⃣ Parse mode (default = local)
# ------------------------------
MODE="${1:-local}"

echo "=== Modalita selezionata: $MODE ==="

# ------------------------------
# 2️⃣ Verify Docker is running
# ------------------------------
if ! docker info >/dev/null 2>&1; then
    echo "[ERRORE] Docker non e' in esecuzione. Avvia Docker Desktop e riprova."
    exit 1
fi

# ------------------------------
# 3️⃣ Execute requested action
# ------------------------------
case "$MODE" in
    local)
        echo "========================================"
        echo "    TICKETING - RABBITMQ LOCAL DEPLOY"
        echo "========================================"
        # Avvia solo il servizio rabbitmq
        docker compose up -d rabbitmq
        echo "[SUCCESS] RabbitMQ is running."
        echo "Management UI: http://localhost:15672"
        ;;
    down)
        echo "========================================"
        echo "       TICKETING - RABBITMQ DOWN"
        echo "========================================"
        # Ferma e rimuove solo il servizio rabbitmq
        docker compose down -v rabbitmq
        echo "[SUCCESS] RabbitMQ stopped."
        echo "[INFO] Containers and volumes removed."
        ;;
    *)
        echo "[ERRORE] Parametro non valido: \"$MODE\""
        echo "Uso corretto: deploy.sh [local|down]"
        exit 1
        ;;
esac

exit 0
