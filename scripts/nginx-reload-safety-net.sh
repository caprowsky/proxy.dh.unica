#!/bin/sh
# Rete di sicurezza: reload giornaliero di nginx nel container proxy.
#
# Il reload "vero" lo fa il deploy hook di certbot subito dopo ogni rinnovo
# (scripts/certbot-deploy-hook.sh). Questo script e' il secondo livello: se
# l'hook viene rimosso, fallisce o il rinnovo viene lanciato con --no-hooks,
# un certificato nuovo entra comunque in servizio entro 24 ore - ampiamente
# dentro i 30 giorni di margine con cui certbot rinnova.
#
# 'nginx -s reload' e' graceful: i worker vecchi chiudono le richieste in corso,
# nessun downtime.
#
# Cron (utente dhwp):
#   30 4 * * * /home/dhwp/proxy.dh.unica/scripts/nginx-reload-safety-net.sh

set -eu

CONTAINER="dhunica_proxypass"
LOG_DIR="$(cd "$(dirname "$0")/.." && pwd)/logs"
LOG="$LOG_DIR/nginx-reload-safety-net.log"

mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%dT%H:%M:%S%z') safety-net: $*" >> "$LOG"
}

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    log "ERRORE: container $CONTAINER non attivo, reload saltato"
    exit 1
fi

if ! docker exec "$CONTAINER" nginx -t >/dev/null 2>&1; then
    log "ERRORE: 'nginx -t' fallito, reload saltato"
    exit 1
fi

docker exec "$CONTAINER" nginx -s reload >/dev/null 2>&1
log "reload $CONTAINER OK"
