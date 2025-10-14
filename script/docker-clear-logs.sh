#!/bin/bash
# Svuota tutti i log JSON dei container Docker più grandi

find /var/lib/docker/containers -name '*.log' -size +100M | while read log; do
    echo "Svuoto $log"
    sudo truncate -s 0 "$log"
done
