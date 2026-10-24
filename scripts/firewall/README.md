# Porte dei backend riservate al proxy

`solo-dal-proxy.sh` scarta, nella catena `DOCKER-USER`, le connessioni verso le porte indicate che arrivano dall'interfaccia esterna e non dal reverse proxy (`90.147.144.144`). Le porte pubblicate da Docker non passano dalla catena `INPUT`, quindi ufw e regole su `INPUT` non bastano.

| VM | Porte | Perché |
|---|---|---|
| dhwp2 · 90.147.144.156 | 8000 | MediaWiki (PHP 7.4) era raggiungibile da Internet senza passare dal proxy |
| dhpasteur · 90.147.144.180 | 8000 | luoghimemoriaeuropa (PHP 8.2.9) era raggiungibile da Internet senza passare dal proxy |

La configurazione di ogni VM sta in `hosts/<vm>.conf`.

## Installazione su una VM

Si esegue come root. Prima va scelta la VM e verificato il nome dell'interfaccia con `ip -br addr`.

```sh
install -m 0755 solo-dal-proxy.sh /usr/local/sbin/solo-dal-proxy.sh
install -m 0644 hosts/<vm>.conf /etc/default/solo-dal-proxy
install -m 0644 solo-dal-proxy.service /etc/systemd/system/solo-dal-proxy.service
systemctl daemon-reload
systemctl enable --now solo-dal-proxy.service
solo-dal-proxy.sh check
```

L'unità systemd riapplica le regole all'avvio e a ogni riavvio di Docker. Lo script è idempotente: `apply` non duplica le regole, `remove` le toglie tutte.

## Verifica

- Da Internet (fuori dalla VPN) la porta non risponde: `curl -m 6 http://<ip-vm>:8000/` va in timeout.
- Attraverso il proxy il sito risponde come prima.

## Rollback

```sh
systemctl disable --now solo-dal-proxy.service   # ExecStop toglie le regole
```
