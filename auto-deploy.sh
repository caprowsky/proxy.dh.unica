#!/bin/bash
# Auto-deploy script con controllo git
# File: /home/dhwp/auto-deploy.sh

PROJECT_DIR="/home/dhwp/proxy.dh.unica"
LOCK_FILE="/tmp/auto-deploy.lock"

# Evita esecuzioni multiple
if [ -f "$LOCK_FILE" ]; then
    echo "Deploy già in corso..."
    exit 0
fi

# Crea lock file
touch "$LOCK_FILE"

# Cleanup function
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

cd "$PROJECT_DIR"

# Controlla se ci sono nuovi commit
git fetch origin >/dev/null 2>&1

LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/master)

if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
    echo "$(date): 🔄 Nuovi commit trovati - Deploy automatico in corso..."
    
    # Pull dei nuovi commit
    git reset --hard origin/master
    git pull origin master
    
    # Reload nginx
    chmod +x nginx-reload.sh
    ./nginx-reload.sh
    
    # Verifica nginx
    docker exec dhunica_proxypass nginx -t
    
    echo "$(date): ✅ Deploy automatico completato!"
    echo "$(date): 📝 Commit: $REMOTE_COMMIT"
else
    echo "$(date): 💤 Nessun nuovo commit"
fi