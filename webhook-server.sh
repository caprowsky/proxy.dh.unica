#!/bin/bash
# Simple webhook server per auto-deploy
# Usage: ./webhook-server.sh [PORT]

PORT=${1:-9000}
DEPLOY_SCRIPT="/home/dhwp/proxy.dh.unica/docker-deploy.sh"

echo "🌐 Starting webhook server on port $PORT..."
echo "📡 Webhook URL: http://90.147.144.144:$PORT/deploy"

while true; do
    # Ascolta richieste HTTP
    { 
        echo "HTTP/1.1 200 OK"
        echo "Content-Type: text/plain"
        echo ""
        echo "Deploy webhook received at $(date)"
    } | nc -l -p $PORT -q 1
    
    echo "📥 Deploy webhook triggered! $(date)"
    
    # Esegui deploy
    if [ -f "$DEPLOY_SCRIPT" ]; then
        chmod +x "$DEPLOY_SCRIPT"
        "$DEPLOY_SCRIPT"
    else
        echo "❌ Deploy script not found: $DEPLOY_SCRIPT"
    fi
    
    echo "---"
done