#!/bin/sh

sudo -H certbot-auto renew && docker exec -it arrubiu_nginx  nginx -s reload


