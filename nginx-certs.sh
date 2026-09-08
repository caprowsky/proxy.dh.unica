#!/bin/sh
# Rinnovo manuale dei certificati Let's Encrypt.
#
# Il rinnovo automatico e' gia' gestito dal timer snap.certbot.renew (2 volte
# al giorno) + il deploy hook che ricarica nginx: questo script serve solo per
# forzare un rinnovo a mano.
#
# Nota: si usava 'certbot-auto', dismesso da Let's Encrypt nel 2021 e non piu'
# funzionante; ora certbot e' installato come snap ed e' in /usr/bin/certbot.

sudo certbot renew && docker exec dhunica_proxypass nginx -s reload
