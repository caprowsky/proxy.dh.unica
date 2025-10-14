#!/bin/bash
# Report dettagliato dello spazio usato da Docker

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
