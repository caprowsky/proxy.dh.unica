#!/bin/bash
# Script per configurare il GitHub Actions Runner
# Usage: ./setup-runner.sh YOUR_TOKEN_HERE

TOKEN=$1

if [ -z "$TOKEN" ]; then
    echo "❌ Error: Token mancante!"
    echo "Usage: ./setup-runner.sh YOUR_GITHUB_TOKEN"
    echo ""
    echo "Per ottenere il token:"
    echo "1. Vai su https://github.com/caprowsky/proxy.dh.unica/settings/actions/runners"
    echo "2. Clicca 'New self-hosted runner'"
    echo "3. Copia il token dalla pagina"
    exit 1
fi

echo "🚀 Configurando GitHub Actions Runner..."

cd /home/dhwp/actions-runner

# Configura il runner
./config.sh --url https://github.com/caprowsky/proxy.dh.unica --token $TOKEN --name "dh-unica-server" --work /home/dhwp/actions-runner/_work --labels self-hosted,Linux,X64,dh-unica

echo "✅ Runner configurato!"
echo "💡 Per avviare il runner:"
echo "   ./run.sh"
echo ""
echo "💡 Per installare come servizio:"
echo "   sudo ./svc.sh install"
echo "   sudo ./svc.sh start"