#!/bin/bash
# Installa scripts/certbot-deploy-hook.sh fra i deploy hook di certbot.
#
# Uso (sul server del proxy):
#   ./scripts/install-certbot-deploy-hook.sh            # usa sudo
#   ./scripts/install-certbot-deploy-hook.sh --via-docker # usa il bind mount
#                                                         # /etc/letsencrypt del
#                                                         # container (serve solo
#                                                         # il gruppo docker)
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/certbot-deploy-hook.sh"
DEST_DIR="/etc/letsencrypt/renewal-hooks/deploy"
DEST_NAME="00-reload-dhunica-proxy.sh"
DEST="$DEST_DIR/$DEST_NAME"
CONTAINER="dhunica_proxypass"

if [ ! -f "$SRC" ]; then
    echo "ERRORE: script sorgente non trovato: $SRC" >&2
    exit 1
fi

if [ "${1:-}" = "--via-docker" ]; then
    # Il container monta /etc/letsencrypt dall'host e gira come root:
    # scrivere qui equivale a scrivere sull'host.
    docker exec -i "$CONTAINER" sh -c "mkdir -p '$DEST_DIR' && cat > '$DEST' && chmod 755 '$DEST'" < "$SRC"
    docker exec "$CONTAINER" ls -l "$DEST"
else
    sudo install -o root -g root -m 755 "$SRC" "$DEST"
    sudo ls -l "$DEST"
fi

echo "Hook installato in $DEST"
echo "Verifica a vuoto:  sudo certbot renew --dry-run --run-deploy-hooks"
