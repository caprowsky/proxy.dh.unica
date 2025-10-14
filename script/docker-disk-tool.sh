#!/bin/bash
# Tool unico per analisi e pulizia spazio Docker
# Uso: ./docker-disk-tool.sh [report|volumes|volumes-containers|clear-logs|clear-big]

usage() {
    echo "Uso: $0 [report|volumes|volumes-containers|clear-logs|clear-big]"
    echo "  report            - Report completo dello spazio Docker"
    echo "  volumes           - Dimensione di tutti i volumi Docker"
    echo "  volumes-containers- Volumi, dimensione e container associati"
    echo "  clear-logs        - Svuota i log JSON dei container >100M"
    echo "  clear-big         - Svuota file >1G in /var/lib/docker/containers"
}

case "$1" in
    report)
        echo "==== Spazio totale /var/lib/docker ===="
        sudo du -sh /var/lib/docker
        echo -e "\n==== Directory principali in /var/lib/docker ===="
        sudo du -h --max-depth=1 /var/lib/docker | sort -hr
        echo -e "\n==== Volumi Docker ===="
        for v in $(docker volume ls -q); do
            path=$(docker volume inspect --format '{{.Mountpoint}}' $v)
            size=$(sudo du -sh "$path" 2>/dev/null | awk '{print $1}')
            echo "$v : $size ($path)"
        done
        echo -e "\n==== Container: dimensione dati e log ===="
        sudo du -h --max-depth=1 /var/lib/docker/containers | sort -hr
        echo -e "\n==== Overlay2/layer: dimensione ===="
        sudo du -h --max-depth=1 /var/lib/docker/overlay2 | sort -hr
        echo -e "\n==== 20 directory/file più grandi in /var/lib/docker ===="
        sudo du -h --max-depth=2 /var/lib/docker | sort -hr | head -20
        ;;
    volumes)
        echo "Volumi Docker e dimensione:"
        for v in $(docker volume ls -q); do
            path=$(docker volume inspect --format '{{.Mountpoint}}' $v)
            size=$(sudo du -sh "$path" 2>/dev/null | awk '{print $1}')
            echo "$v : $size ($path)"
        done
        ;;
    volumes-containers)
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
        ;;
    clear-logs)
        find /var/lib/docker/containers -name '*.log' -size +100M | while read log; do
            echo "Svuoto $log"
            sudo truncate -s 0 "$log"
        done
        ;;
    clear-big)
        find /var/lib/docker/containers -type f -size +1G | while read f; do
            echo "Svuoto $f"
            sudo truncate -s 0 "$f"
        done
        ;;
    *)
        usage
        ;;
esac
