# Spostamento del repository in Dh-unica e sicurezza del proxy

Valutazione del 5 novembre 2026. È solo un'analisi: il repository non è stato spostato e sul proxy non è stato cambiato nulla.

> **Il repository è pubblico.** Questo file non riporta account, posizione di credenziali e catene di attacco: quei dettagli stanno nelle note locali del manutentore.

## In sintesi

- **Spostamento:** impatto basso sul CD, non dovrebbe fermare nulla. Va fatto insieme alla protezione di `master`.
- **Assessment di sicurezza del proxy:** non esiste. Ci sono documenti vicini (sezione 2.1); la sezione 2.5 spiega come impostarlo.
- **Proxy:** nginx 1.10.3 su Ubuntu 16.04, entrambi senza più aggiornamenti. La raccomandazione è passare a nginx 1.30 mantenendo le configurazioni attuali, senza cambiare prodotto.

## 1. Spostamento del repository

Da `caprowsky/proxy.dh.unica` a `Dh-unica/proxy.dh.unica`.

### 1.1 Come funziona oggi il deploy

Il deploy non passa da GitHub Actions. Sul server gira questo cron, che allinea il checkout a `origin/master` e ricarica nginx:

```cron
* * * * * /home/dhwp/proxy.dh.unica/auto-deploy.sh >> /home/dhwp/auto-deploy.log 2>&1
```

Il remote del server è `git@github.com:caprowsky/proxy.dh.unica.git`. Cron e remote risultano da una verifica del 30 ottobre 2026.

Secondo la documentazione di GitHub, dopo un trasferimento `git clone`, `git fetch` e `git push` vengono reindirizzati al nuovo indirizzo. Il cron quindi continua a funzionare anche senza toccare il server.

Sul repository (API GitHub, 5 novembre) non c'è niente da migrare: 0 secret, 0 variabili, 0 webhook, 0 deploy key, 0 runner, 0 fork, nessuna GitHub Pages, nessuna PR o issue aperta. Nell'org il nome è libero e l'account del manutentore può trasferire il repository.

### 1.2 Impatto su CI/CD

| Componente | Cosa succede | Cosa fare |
|---|---|---|
| Cron di deploy | Continua grazie al redirect | `git remote set-url` sul server, poi prova con un commit vero |
| `main-deploy.yml` | Continua: stampa solo una notifica, senza nomi hardcoded. Su `Dh-unica/aiucd` tutte le action sono consentite | Correggerlo (sezione 3) |
| GitGuardian | Probabilmente si ferma: gira sulle ultime 4 PR, ma non compare su quelle di `lizmap.dh.unica.it` e `aiucd` | Installarlo sull'org e controllare la prima PR |
| Copilot code review | Continua: è già attivo su `lizmap.dh.unica.it` | Niente |
| `docker-runner.sh`, `setup-runner.sh`, `.env.example` | Contengono il vecchio URL, ma nessun runner è registrato | Eliminarli |
| Workflow `*.disabled`, ambienti `Production` e `copilot` | Inutilizzati | Pulizia facoltativa |

Due punti di attenzione:

- **Un guasto del deploy non si vede.** `auto-deploy.sh` scarta gli errori di `git fetch`, quindi un fetch rotto appare nel log come "Nessun nuovo commit". Dopo lo spostamento non basta leggere il log: serve un commit di prova.
- **Il redirect è fragile.** Un nuovo repository `caprowsky/proxy.dh.unica` lo cancellerebbe per sempre.

### 1.3 Riferimenti da aggiornare

Restano validi grazie al redirect, ma vanno corretti.

- **In questo repository:** `README.md:72` e `:521`. Gli altri (`.env.example`, `docker-runner.sh`, `setup-runner.sh`) spariscono con la rimozione dei file.
- **In altri repository:**
  - `lizmap.dh.unica.it/README.md`
  - `mergin.dh.unica.it/README.md`
  - `geonode.dh.unica.it/README.md`
  - `atliteg-map/CLAUDE.md`
  - `atliteg-map/docs/guides/multi-domain-deployment.md`
  - `almanaccostampasarda/deploy/mockup/docker-compose.yml`
  - `almanaccostampasarda/mockup/README.md`
  - `mergin-lizmap/PIANO-MIGRAZIONE.md`
- **Fuori da git:** l'inventario degli applicativi su Drive.
- **Da lasciare:** i riferimenti storici alle PR nei report di `dh-unica_monitoring`.

### 1.4 Accessi e protezioni

Scrivere su `master` equivale ad avere accesso al server, perché il cron esegue entro un minuto script presi dal repository. `master` oggi non ha protezioni, e lo spostamento allarga la platea:

- gli owner dell'org ottengono accesso amministrativo;
- l'org non impone la 2FA: prima di dare scrittura ad altri membri va verificato che l'abbiano attiva.

**Modello da copiare:** `Dh-unica/lizmap.dh.unica.it` ha `main` protetto con il check obbligatorio `regole`, niente force push né cancellazione, regole applicate anche agli admin. Il controllo sta in `.github/workflows/regole-git.yml` e `.githooks/pre-commit`. Qui andrebbe aggiunto un check `nginx -t`, oggi fatto a mano prima del merge. Il nome del branch va adattato a `master`.

**Il repository deve restare pubblico.** Sul piano Free un repository privato perde la protezione dei branch.

**Chiave SSH del server.** Il repository non ha deploy key, quindi quella usata dal server appartiene a un account o a un altro repository: va verificata (sezione 4). Altri server del DH usano deploy key per repository, e il proxy dovrebbe fare lo stesso.

### 1.5 Procedura consigliata

**Prima:**

1. Eseguire le verifiche della sezione 4.
2. Installare GitGuardian sull'org.
3. Unire una PR con gli interventi della sezione 3 e la rimozione degli script morti.

**Spostamento:**

1. Trasferire il repository da *Settings > Danger Zone > Transfer*, oppure con:
   ```sh
   gh api repos/caprowsky/proxy.dh.unica/transfer -f new_owner=Dh-unica
   ```
2. Aggiornare il remote sul server e controllare che il fetch non dia errori:
   ```sh
   git -C ~/proxy.dh.unica remote set-url origin git@github.com:Dh-unica/proxy.dh.unica.git
   git -C ~/proxy.dh.unica fetch origin
   ```
3. Unire una piccola PR di prova e controllare che sul server `git rev-parse HEAD` coincida con `origin/master` entro un paio di minuti.
4. Aggiornare il remote dei cloni locali.
5. Attivare la protezione di `master` come in `lizmap.dh.unica.it`.
6. Aggiornare i riferimenti della sezione 1.3.
7. Passare a una deploy key in sola lettura. GitHub non permette di riusare una deploy key su due repository, e sulla stessa VM c'è anche il checkout di `dh.unica`, quindi serve una chiave dedicata:
   ```sh
   ssh-keygen -t ed25519 -f ~/.ssh/proxy_deploy -N ''
   # aggiungere la chiave pubblica al repository, in sola lettura, poi:
   git -C ~/proxy.dh.unica config core.sshCommand "ssh -i ~/.ssh/proxy_deploy -o IdentitiesOnly=yes"
   ```

**Rollback:** il repository si può ritrasferire su `caprowsky` e il remote si riporta al vecchio valore.

## 2. Sicurezza del proxy

### 2.1 Documentazione esistente

Un assessment del proxy non è stato trovato. Le ricerche hanno coperto il repository (branch e file cancellati compresi), le cartelle DH, le sessioni di lavoro disponibili e Drive.

| Documento | Cosa copre |
|---|---|
| `dh-unica_monitoring/reports/2026-10-24-tutte-php2shell.md` e i due report collegati | Vulnerabilità PHP2Shell nei backend. Il proxy compare come punto di blocco, nginx non viene valutato |
| `doc/SECURITY-RESOLUTION.md` | Token GitHub esposto, ottobre 2025 |
| `scripts/firewall/README.md` | Porte dirette dei backend su due VM |
| "DH UNICA » Ottimizzazione server" (Drive) | Storage e backup |

### 2.2 Quadro di partenza

Rilevato il 5 novembre 2026 dall'esterno e dai file del repository, senza accesso al server salvo dove indicato.

| Area | Risultato | Fonte |
|---|---|---|
| nginx | 1.10.3, fine vita 12 aprile 2017. Stabile corrente: 1.30.6 | Header `Server`, endoflife.date |
| Immagine | `ubuntu:16.04`: supporto standard finito il 2 aprile 2021, esteso il 2 aprile 2026 | `Dockerfile`, endoflife.date |
| Host | Ubuntu 18.04: supporto standard finito il 31 maggio 2023, esteso solo con Ubuntu Pro fino al 26 aprile 2028 | `mergin-lizmap/PIANO-MIGRAZIONE.md` |
| TLS | Accetta 1.0, 1.1 e 1.2; 1.3 assente. Accetta suite senza forward secrecy, rifiuta 3DES. Nessun OCSP stapling | `openssl s_client` |
| Protocollo | HTTP/2 non offerto | ALPN |
| Header | Niente HSTS né CSP sui 4 siti provati che hanno risposto; il banner espone la versione | `curl` |
| Configurazione | `nginx.conf` non è nel repository e i vhost non hanno direttive `ssl_*`: la politica TLS vive nell'immagine | Repository |
| Rate limit | Nessun `limit_req` nei vhost | Repository |
| README | Dichiara "Headers di sicurezza standard", ma gli unici `add_header` dei vhost sono `X-Robots-Tag` e `Cache-Control` | Repository |
| Immagine | Include `build-essential`; le cartelle dei certificati sono montate in scrittura | `Dockerfile`, `docker-compose.yml` |
| Log e disco | Log senza rotazione e disco pieno a maggio 2026: da riverificare | Note di esercizio |
| Differenze con il repository | File `.bak` non tracciato in `sites-enabled/` di produzione, caricato da nginx (24 ottobre): da riverificare | Report PHP2Shell |

**Già fatto:** blocco dello strumento PHP2Shell e dei file riservati sul proxy, firewall sulle porte dirette di due VM, SSH solo dalla VPN d'ateneo.

**Problemi già noti:** certificati scaduti o errati e backend in errore sono elencati nella PR #26.

### 2.3 Vulnerabilità note

Le advisory di nginx.org che includono la 1.10.3 sono 27: 7 fino al 2019 e 20 dal 2021 in poi, di cui 15 del 2026. Il confronto con i vhost le ridimensiona molto:

| Esito | Quante | Dettaglio |
|---|---|---|
| Funzione non configurata nei vhost | 22 | HTTP/2, mp4, mail, dav, scgi/uwsgi, SSI, charset, AIO, `alias`, upstream TLS |
| Funzione usata, ma schema diverso da quello vulnerabile | 2 | CVE-2026-42945 e CVE-2026-9256, sull'unico `rewrite` presente |
| Da verificare | 3 | Vedi sotto |

- **CVE-2026-42533** (`map` con regex, CVSS 8.1): il costrutto è usato in `00-php2shell.conf` e `00-file-riservati.conf`. Le variabili di cattura non sono referenziate, quindi la condizione principale non sembra presente, ma l'advisory ne cita una seconda più generica.
- **CVE-2021-23017** (`resolver`): usato in `storia_dhunica.conf`, solo verso il DNS interno di Docker. Esposizione bassa.
- **CVE-2017-7529** (range filter): dovrebbe essere corretta nei pacchetti Ubuntu. Va controllato il pacchetto installato.

Limite di questa analisi: `nginx.conf` dentro l'immagine non è stato letto.

Il rischio principale non è una singola CVE: su questa versione non arriveranno più correzioni, e la prossima vulnerabilità in una funzione usata resterebbe aperta.

### 2.4 Mettere in sicurezza, aggiornare o cambiare

| Opzione | Valutazione |
|---|---|
| Solo hardening della configurazione | Non basta: migliora TLS e header, ma non porta né patch né TLS 1.3. Le stesse correzioni vanno comunque fatte con l'aggiornamento |
| **Aggiornare a nginx 1.30 (consigliata)** | Sembra poco costoso: 40 file e 2.574 righe, senza moduli di terze parti, `include` o `ssl on`. Risolve la mancanza di patch e porta `nginx.conf` nel repository |
| Sostituire (Caddy, Traefik, HAProxy) | Costringe a riscrivere tutte le configurazioni senza un vantaggio chiaro. Da riconsiderare solo se l'assessment fa emergere un'esigenza precisa |

Un WAF o CrowdSec sono una decisione separata, da prendere dopo l'assessment: servono soprattutto a proteggere i backend non ancora corretti.

**Cosa comporta l'aggiornamento:**

- L'immagine ufficiale include solo `conf.d/`: serve un `nginx.conf` versionato con `include /etc/nginx/sites-enabled/*;`.
- L'utente del processo cambia, quindi vanno controllati i permessi di `logs/nginx`.
- Va mantenuto il nome `dhunica_proxypass`, usato dagli script e dal deploy hook di certbot.
- `auto-deploy.sh` ricarica nginx ma non ricostruisce l'immagine: il cambio va fatto a mano con `docker compose up -d --build`, con una breve interruzione.
- OpenSSL recente può rifiutare chiavi o certificati deboli, e dalla 1.10 sono cambiate molte impostazioni predefinite: vanno letti i changelog.
- La prova va fatta con un container parallelo su altre porte, confrontando con `curl --resolve` le risposte di tutti gli host con quelle attuali.
- Per il rollback va conservata l'immagine precedente.

### 2.5 Come impostare l'assessment

Stima: 1-2 giornate.

| Area | Domanda | Evidenze |
|---|---|---|
| Software | Cosa è davvero senza patch? | `dpkg -l`, `nginx -T`, scansione dell'immagine con Trivy |
| Esposizione | Cosa si vede da Internet? | testssl.sh e nmap da fuori VPN, porte dirette dei backend |
| Configurazione | I vhost sono corretti? | gixy, HSTS, rate limit, limiti di upload, vhost predefinito |
| Host e container | Quanto danno fa una compromissione? | Privilegi di `dhwp`, mount dei certificati, pacchetti nell'immagine, log, differenze tra repository e server |
| Filiera di deploy | Chi arriva in produzione? | gitleaks sulla storia, chiave SSH del server, 2FA, protezioni, workflow |

Regole di lavoro:

- Solo raccolta di evidenze in lettura, nessun tentativo di sfruttamento.
- Avvisare il servizio sicurezza d'Ateneo prima delle scansioni esterne.
- Assegnare le severità in base a ciò che è raggiungibile con questa configurazione, non alla sola versione.
- Scrivere il risultato in un repository non pubblico: `dh-unica_monitoring/reports/AAAA-MM-GG-dhwp-proxy-assessment.md`.
- Chiudere con la scelta motivata tra le opzioni della sezione 2.4.

## 3. Interventi da non rimandare

Valgono anche se lo spostamento o l'assessment slittano.

- **Proteggere `master`** come descritto nella sezione 1.4.
- **Correggere `main-deploy.yml`:** il messaggio di commit è interpolato direttamente nello script. Va passato da una variabile d'ambiente o tolto, dichiarando `permissions: contents: read`.
- **Togliere gli hash da `htpassword/`** e cambiare le relative password, perché gli hash restano nella storia git. Il `.gitignore` lo prevede già per un file.
- **Non scartare gli errori di `git fetch`** in `auto-deploy.sh`: un fetch fallito deve risultare come errore nel log.

## 4. Da verificare sul server

Nella sessione di valutazione l'accesso SSH alla produzione non era autorizzato. Con la VPN attiva:

```sh
ssh dhwp@90.147.144.144 'cd ~/proxy.dh.unica; git remote -v; ssh -T git@github.com 2>&1 | tail -1; ls sites-enabled/*.bak* 2>/dev/null; docker exec dhunica_proxypass sh -c "dpkg -l nginx-core openssl | tail -2; nginx -T 2>/dev/null | grep -E \"ssl_protocols|ssl_ciphers|server_tokens\""'
```

Le policy Actions dell'org richiedono lo scope `admin:org`:

```sh
gh auth refresh -h github.com -s admin:org
gh api orgs/Dh-unica/actions/permissions
```

## 5. Per riprendere

Stato al 5 novembre 2026: valutazione conclusa, nessun intervento avviato.

- [ ] Eseguire le verifiche della sezione 4
- [ ] Interventi della sezione 3
- [ ] Decidere quando spostare il repository (sezione 1.5)
- [ ] Eseguire l'assessment (sezione 2.5)
- [ ] Decidere e pianificare l'aggiornamento di nginx (sezione 2.4)

## Fonti

- [GitHub: Transferring a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/transferring-a-repository)
- [nginx: security advisories](https://nginx.org/en/security_advisories.html)
- [endoflife.date: nginx](https://endoflife.date/nginx) e [Ubuntu](https://endoflife.date/ubuntu)
