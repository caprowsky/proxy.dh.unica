#!/bin/bash
# Script per monitorare i deploy in tempo reale
# Usage: ./watch-deploy.sh

echo "🔍 Monitoraggio deploy in tempo reale..."
echo "📅 Ultimo deploy:"
echo ""

# Mostra gli ultimi deploy dal log
ssh -i ~/.ssh/proxy_unica dhwp@90.147.144.144 'tail -n 20 /home/dhwp/auto-deploy.log 2>/dev/null | grep -E "(🔄|✅|❌)" || echo "Nessun deploy recente"'

echo ""
echo "📊 Statistiche deploy oggi:"
ssh -i ~/.ssh/proxy_unica dhwp@90.147.144.144 "grep '$(date +%Y-%m-%d)' /home/dhwp/auto-deploy.log 2>/dev/null | grep -c '✅' | awk '{print \"Deploy completati: \" \$1}'"

echo ""
echo "⏰ Per monitorare in tempo reale:"
echo "   ssh dhwp@90.147.144.144 'tail -f /home/dhwp/auto-deploy.log'"