#!/bin/bash
# Elenca tutti i volumi Docker e mostra la dimensione su disco

echo "Volumi Docker e dimensione:"
for v in $(docker volume ls -q); do
    path=$(docker volume inspect --format '{{.Mountpoint}}' $v)
    size=$(sudo du -sh "$path" 2>/dev/null | awk '{print $1}')
    echo "$v : $size ($path)"
done
