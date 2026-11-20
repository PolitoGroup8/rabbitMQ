#!/bin/sh
set -eu

: "${RABBITMQ_USER:?RABBITMQ_USER non impostata}"
: "${RABBITMQ_PASSWORD:?RABBITMQ_PASSWORD non impostata}"

OUT_DIR="/etc/rabbitmq/definitions"
OUT_FILE="$OUT_DIR/definitions.json"
TEMPLATE_FILE="/templates/definitions.json.template"

mkdir -p "$OUT_DIR"

# Se sull'host era rimasta una directory vuota chiamata definitions.json, avvisa chiaramente
if [ -d "$OUT_FILE" ]; then
  echo "ERRORE: $OUT_FILE è una directory. Rimuovila sull'host e riavvia." >&2
  exit 1
fi

ESC_USER=$(printf '%s' "$RABBITMQ_USER" | sed 's/[&/\]/\\&/g')
ESC_PASS=$(printf '%s' "$RABBITMQ_PASSWORD" | sed 's/[&/\]/\\&/g')

sed -e "s/\${RABBITMQ_USER}/$ESC_USER/g" \
    -e "s/\${RABBITMQ_PASSWORD}/$ESC_PASS/g" \
    "$TEMPLATE_FILE" > "$OUT_FILE"

exec /usr/local/bin/docker-entrypoint.sh rabbitmq-server