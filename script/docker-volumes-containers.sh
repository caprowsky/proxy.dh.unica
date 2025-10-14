#!/bin/bash
# Mostra per ogni volume: dimensione, path e container associati tramite nome volume

for v in $(docker volume ls -q); do
    path=$(docker volume inspect --format '{{.Mountpoint}}' $v)
    size=$(sudo du -sh "$path" 2>/dev/null | awk '{print $1}')
    echo "Volume: $v"
    echo "  Path: $path"
    echo "  Size: $size"
    echo "  Usato da container:"
    for cid in $(docker ps -q); do
        if docker inspect $cid | grep -q "$v"; then
            name=$(docker inspect --format '{{.Name}}' $cid | cut -c2-)
            echo "    - $name ($cid)"
        fi
    done
    echo ""
done
