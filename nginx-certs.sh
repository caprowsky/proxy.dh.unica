#!/bin/sh

sudo -H certbot-auto renew && docker exec -it dhunica_proxypass  nginx -s reload
