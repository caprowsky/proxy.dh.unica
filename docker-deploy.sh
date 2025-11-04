#!/bin/bash
# Script per deploy con Docker invece di GitHub Actions
# Salva come: /home/dhwp/docker-deploy.sh

echo "🚀 Starting Docker-based deploy..."

# Naviga nella directory del progetto
cd /home/dhwp/proxy.dh.unica

# Pull del codice aggiornato
echo "📥 Pulling latest code..."
git fetch origin
git reset --hard origin/master
git pull origin master

# Reload nginx
echo "🔄 Reloading Nginx..."
chmod +x nginx-reload.sh
./nginx-reload.sh

# Verifica nginx
echo "✅ Verifying Nginx..."
docker exec dhunica_proxypass nginx -t

echo "🎉 Deploy completed successfully at $(date)"