#!/bin/bash
# Script per avviare GitHub Actions runner in Docker
# File: docker-runner.sh

echo "🐳 Starting GitHub Actions Runner in Docker..."

# Carica variabili d'ambiente da file .env se esiste
if [ -f ".env" ]; then
  echo "📄 Caricando configurazione da .env..."
  export $(grep -v '^#' .env | xargs)
fi

# Ferma eventuali container esistenti
docker stop github-runner 2>/dev/null || true
docker rm github-runner 2>/dev/null || true

# Avvia il runner in Docker
# IMPORTANTE: Imposta la variabile d'ambiente RUNNER_TOKEN prima di eseguire questo script
# export RUNNER_TOKEN="your-token-here"
if [ -z "$RUNNER_TOKEN" ]; then
  echo "❌ Errore: RUNNER_TOKEN non impostato!"
  echo "💡 Esegui: export RUNNER_TOKEN=\"your-token-here\""
  exit 1
fi

docker run -d --name github-runner \
  --restart unless-stopped \
  -e RUNNER_NAME="dh-unica-docker" \
  -e RUNNER_TOKEN="$RUNNER_TOKEN" \
  -e RUNNER_REPOSITORY_URL="https://github.com/caprowsky/proxy.dh.unica" \
  -e RUNNER_LABELS="self-hosted,Linux,X64,docker" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/dhwp/proxy.dh.unica:/workspace \
  myoung34/github-runner:latest

echo "✅ Runner Docker avviato!"
echo "📋 Controlla con: docker logs github-runner"