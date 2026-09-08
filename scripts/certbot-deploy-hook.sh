#!/bin/sh
# Deploy hook di certbot: ricarica nginx nel container proxy dopo ogni rinnovo.
#
# Perche' serve: certbot rinnova i certificati in /etc/letsencrypt/live, ma nginx
# tiene in memoria quelli caricati all'avvio. Senza questo hook il container
# continua a servire il certificato vecchio finche' non viene riavviato a mano
# (e' successo con atlante.atliteg.org: cert rinnovato l'08/08/2026, ma il
# certificato servito e' scaduto il 07/09/2026 perche' nginx non e' mai stato
# ricaricato).
#
# Installazione: scripts/install-certbot-deploy-hook.sh
# Certbot lo esegue come root, una volta per ogni lineage rinnovato, con
# RENEWED_LINEAGE e RENEWED_DOMAINS valorizzati.

set -eu

CONTAINER="dhunica_proxypass"
DOCKER="/usr/bin/docker"
LOG="/var/log/certbot-deploy-hook.log"

log() {
    msg="$(date '+%Y-%m-%dT%H:%M:%S%z') certbot-deploy-hook: $*"
    echo "$msg"
    # Log su file best-effort: se non e' scrivibile (hook lanciato da un utente
    # non root per una prova) resta comunque lo stdout, che certbot cattura nel
    # proprio log in /var/log/letsencrypt/.
    # 2>/dev/null va PRIMA di >>: in sh le redirezioni si applicano da
    # sinistra a destra, altrimenti l'errore della redirezione stessa sfugge.
    echo "$msg" 2>/dev/null >> "$LOG" || true
}

if [ ! -x "$DOCKER" ]; then
    log "ERRORE: $DOCKER non disponibile, reload saltato"
    exit 1
fi

if ! "$DOCKER" ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    log "ERRORE: container $CONTAINER non attivo, reload saltato"
    exit 1
fi

# nginx -t prima del reload: una config rotta non deve buttare giu' il proxy.
if ! "$DOCKER" exec "$CONTAINER" nginx -t >/dev/null 2>&1; then
    log "ERRORE: 'nginx -t' fallito in $CONTAINER, reload saltato"
    "$DOCKER" exec "$CONTAINER" nginx -t 2>&1 || true
    exit 1
fi

"$DOCKER" exec "$CONTAINER" nginx -s reload >/dev/null 2>&1
log "reload $CONTAINER OK (domini: ${RENEWED_DOMAINS:-n/d})"
