#!/bin/sh

# Niente flag -it: l'auto-deploy gira da cron senza TTY e "-t" lo farebbe
# fallire con "the input device is not a TTY", saltando il reload di nginx.
docker exec dhunica_proxypass nginx -s reload
