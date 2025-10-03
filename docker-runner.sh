#!/bin/bash
# Script per avviare GitHub Actions runner in Docker
# File: docker-runner.sh

echo "🐳 Starting GitHub Actions Runner in Docker..."

# Ferma eventuali container esistenti
docker stop github-runner 2>/dev/null || true
docker rm github-runner 2>/dev/null || true

# Avvia il runner in Docker
docker run -d --name github-runner \
  --restart unless-stopped \
  -e RUNNER_NAME="dh-unica-docker" \
  -e RUNNER_TOKEN="AABJOTQKHMSLHE5O5ICDPB3I36ZP4" \
  -e RUNNER_REPOSITORY_URL="https://github.com/caprowsky/proxy.dh.unica" \
  -e RUNNER_LABELS="self-hosted,Linux,X64,docker" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /home/dhwp/proxy.dh.unica:/workspace \
  myoung34/github-runner:latest

echo "✅ Runner Docker avviato!"
echo "📋 Controlla con: docker logs github-runner"