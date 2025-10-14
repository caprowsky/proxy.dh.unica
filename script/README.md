# Docker Disk Tool

Questo script unico permette di analizzare e gestire lo spazio occupato da Docker sul server, individuando rapidamente le cause di saturazione del disco e fornendo strumenti per la pulizia.

## Utilizzo

Rendi lo script eseguibile:
```bash
chmod +x docker-disk-tool.sh
```

Esegui lo script con uno dei seguenti parametri:

- `report`             : Report completo dello spazio usato da Docker (directory, volumi, container, layer, file più grandi)
- `volumes`            : Elenca tutti i volumi Docker e la loro dimensione
- `volumes-containers` : Mostra per ogni volume la dimensione, il path e i container che lo utilizzano
- `clear-logs`         : Svuota tutti i file di log JSON dei container Docker più grandi (>100MB)
- `clear-big`          : Svuota tutti i file >1GB nella directory dei container (utile per log o file temporanei)

Esempi:
```bash
./docker-disk-tool.sh report
./docker-disk-tool.sh clear-logs
```

## Note
- Alcune operazioni richiedono permessi di root (sudo).
- La pulizia dei log non interrompe i container.
- Usare con cautela la funzione `clear-big` se non si conosce la natura dei file.

---

Script creato per facilitare la gestione dello spazio disco in ambienti Docker complessi.
