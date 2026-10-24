#!/bin/sh
# Porte pubblicate da Docker su una VM, raggiungibili solo dal reverse proxy (dhwp).
#
# Perche' serve: i backend dietro il proxy pubblicano porte su 0.0.0.0. Il firewall
# d'ateneo ne filtra quasi tutte, ma al 24/10/2026 la 8000 di dhwp2 (MediaWiki) e di
# dhpasteur (luoghimemoriaeuropa) erano raggiungibili da Internet: arrivavano a PHP
# senza passare dal proxy, e quindi senza le sue protezioni (PHP2Shell, ottobre 2026).
#
# Le porte pubblicate da Docker non passano dalla catena INPUT: il filtro sta in
# DOCKER-USER e guarda la porta originale con conntrack, perche' dopo il DNAT la
# porta di destinazione e' gia' quella del container.
#
# Uso: solo-dal-proxy.sh apply|remove|check
# Configurazione (variabili d'ambiente o /etc/default/solo-dal-proxy):
#   PORTS="8000"      porte dell'host da riservare al proxy
#   IFACE=ens160      interfaccia esterna della VM
#   ALLOW=90.147.144.144  indirizzo del reverse proxy
# Installazione e verifica: vedi README.md in questa cartella.

set -eu

[ -r /etc/default/solo-dal-proxy ] && . /etc/default/solo-dal-proxy
: "${PORTS:?PORTS non impostato}"
: "${IFACE:?IFACE non impostato}"
: "${ALLOW:=90.147.144.144}"
TAG="solo-dal-proxy"

# $1 = -C (esiste?), -I (inserisci in cima) o -D (togli); $2 = porta
rule() {
    iptables "$1" DOCKER-USER -i "$IFACE" -p tcp \
        -m conntrack --ctorigdstport "$2" --ctdir ORIGINAL \
        ! -s "$ALLOW" -m comment --comment "$TAG:$2" -j DROP
}

case "${1:-}" in
    apply)
        if ! iptables -n -L DOCKER-USER >/dev/null 2>&1; then
            echo "catena DOCKER-USER assente: Docker non e' ancora partito?" >&2
            exit 1
        fi
        for port in $PORTS; do
            rule -C "$port" 2>/dev/null || rule -I "$port"
        done
        ;;
    remove)
        for port in $PORTS; do
            while rule -C "$port" 2>/dev/null; do rule -D "$port"; done
        done
        ;;
    check)
        iptables -S DOCKER-USER | grep -- "$TAG" || echo "nessuna regola $TAG"
        ;;
    *)
        echo "uso: $0 apply|remove|check" >&2
        exit 2
        ;;
esac
