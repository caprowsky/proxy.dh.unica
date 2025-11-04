#!/bin/bash
# Script per deploy locale tramite webhook
# Salva come: /home/dhwp/deploy-webhook.sh

PORT=${1:-8080}

echo "🚀 Starting deploy webhook server on port $PORT..."

# Semplice server webhook con netcat
while true; do
    echo -e "HTTP/1.1 200 OK\r\nContent-Length: 23\r\n\r\nDeploy webhook received" | nc -l -p $PORT -q 1
    
    echo "📥 Webhook received! Starting deploy..."
    
    # Naviga nella directory del progetto
    cd /home/dhwp/proxy.dh.unica
    
    # Pull del codice aggiornato
    echo "🔄 Updating code from Git..."
    git fetch origin
    git reset --hard origin/master
    git pull origin master
    
    # Reload nginx
    echo "🔄 Reloading Nginx..."
    chmod +x nginx-reload.sh
    ./nginx-reload.sh
    
    echo "✅ Deploy completed at $(date)"
    echo "---"
done