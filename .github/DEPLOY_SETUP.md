# GitHub Actions Deploy Setup

Questo repository include due GitHub Actions per automatizzare il deploy:

## 1. `deploy.yml` - Deploy Completo
Esegue un rebuild completo del container quando viene fatto push su master.

## 2. `nginx-reload.yml` - Reload Semplice  
Esegue solo il reload della configurazione nginx (più veloce, senza downtime).

## Configurazione dei Secrets

Per far funzionare le GitHub Actions, devi configurare i seguenti secrets nel repository GitHub:

1. Vai su **Settings** → **Secrets and variables** → **Actions**
2. Aggiungi i seguenti secrets:

### Secrets Richiesti:

- **`HOST`**: L'indirizzo IP o hostname del tuo server
  ```
  Esempio: 90.147.144.145
  ```

- **`USERNAME`**: Username per la connessione SSH
  ```  
  Esempio: ale
  ```

- **`SSH_PRIVATE_KEY`**: La chiave privata SSH per connettersi al server
  ```
  Il contenuto del file ~/.ssh/id_rsa (o della tua chiave privata)
  Assicurati che sia la chiave privata completa, inclusi:
  -----BEGIN OPENSSH PRIVATE KEY-----
  [contenuto della chiave]
  -----END OPENSSH PRIVATE KEY-----
  ```

- **`PORT`** (opzionale): Porta SSH se diversa da 22
  ```
  Default: 22
  ```

## Setup della Chiave SSH

Se non hai ancora una coppia di chiavi SSH:

```bash
# Genera una nuova coppia di chiavi
ssh-keygen -t rsa -b 4096 -C "github-actions@proxy.dh.unica"

# Copia la chiave pubblica sul server
ssh-copy-id user@your-server.com

# Il contenuto di ~/.ssh/id_rsa va inserito come SSH_PRIVATE_KEY secret
```

## Test della Configurazione

Dopo aver configurato i secrets:

1. Fai un commit e push su master
2. Vai su **Actions** nel repository GitHub  
3. Verifica che il workflow sia eseguito correttamente

## Workflow Scelti

### Per modifiche solo alle configurazioni nginx:
Usa `nginx-reload.yml` - è più veloce e non causa downtime.

### Per modifiche al Dockerfile o docker-compose:  
Usa `deploy.yml` - fa un rebuild completo del container.

## Troubleshooting

- **Permission denied**: Verifica che la chiave SSH sia configurata correttamente
- **Host key verification failed**: Aggiungi il server agli known_hosts o disabilita StrictHostKeyChecking
- **Container not found**: Verifica che il container `dhunica_proxypass` sia in esecuzione