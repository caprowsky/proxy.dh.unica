# Analisi Reverse Proxy DH.UNICA

## Panoramica del Progetto

Questo progetto implementa un reverse proxy bassu su **nginx** che gestisce il traffico per 37 host pubblici (59 URL HTTPS) dell'Università di Cagliari, principalmente focalizzati sulle Digital Humanities. Il reverse proxy è containerizzato con Docker e gestisce sia il traffico HTTP che HTTPS, con certificati SSL configurati.

## Architettura

- **Container**: `dhunica_proxypass` (nginx basato su Ubuntu 16.04)
- **Porte esposte**: 80 (HTTP), 443 (HTTPS)
- **Reti Docker**: `dhunica_default`, `dhunica_laravel_default`
- **Volumi**: Configurazioni nginx, certificati SSL, contenuti web

## Elenco Completo dei Siti Web

### Tabella Completa di Tutti i Siti e Sottopercorsi

| URL Completo | Destinazione Backend | Categoria | Descrizione | Certificati SSL |
|--------------|---------------------|-----------|-------------|------------------|
| **https://dh.unica.it** | `dh.unica_nginx:80` | DH Principale | Portale principale Digital Humanities | DigiCert CA |
| **https://architettura.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Architettura | DigiCert CA |
| **https://archivistica.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Archivistica | DigiCert CA |
| **https://archivistica.dh.unica.it/censoratogenerale** | `90.147.144.147:9000` | DH Sottopercorso | Censorato generale | DigiCert CA |
| **https://archivistica.dh.unica.it/asuca** | `90.147.144.146:8000` | DH Sottopercorso | ASUCA | DigiCert CA |
| **https://almanaccostampasarda.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Almanacco Stampa Sarda | DigiCert CA |
| **https://lizmap.dh.unica.it** | `90.147.144.148:8084` | DH Sottodominio | WebGIS Lizmap (progetto PARC), dhgeo | DigiCert CA |
| **https://lizmap.dh.unica.it/files** | `90.147.144.148:8087` | DH Sottopercorso | Filebrowser dei progetti Lizmap, dhgeo | DigiCert CA |
| **https://mergin.dh.unica.it** | `90.147.144.148:8086` | DH Sottodominio | Mergin Maps CE, rilievi sul campo, dhgeo | DigiCert CA |
| **https://arte.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Arte | DigiCert CA |
| **https://artemusei.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Arte e Musei | DigiCert CA |
| **https://asuca.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto ASUCA | DigiCert CA |
| **https://cinema.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Cinema | DigiCert CA |
| **https://doc.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Documentazione | DigiCert CA |
| **https://docs.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Documentazione | DigiCert CA |
| **https://editoria.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Editoria | DigiCert CA |
| **https://filologia.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Filologia | DigiCert CA |
| **https://geo.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Geografia | DigiCert CA |
| **https://geo.dh.unica.it/geoserver** | `90.147.144.148:80` | DH Sottopercorso | GeoServer | DigiCert CA |
| **https://geografia.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Geografia | DigiCert CA |
| **https://glossari.dh.unica.it** | `90.147.144.147:3001` | DH Sottodominio | Sistema Glossari (frontend Next.js) | DigiCert CA |
| **https://glossari.dh.unica.it/admin** | `90.147.144.147:3000` | DH Sottopercorso | Glossari: amministrazione (Payload CMS) | DigiCert CA |
| **https://glossari.dh.unica.it/api/** | `90.147.144.147:3000` | DH Sottopercorso | Glossari: API (Payload CMS) | DigiCert CA |
| **https://letteratura.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Letteratura | DigiCert CA |
| **https://libriebiblioteche.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Libri e Biblioteche | DigiCert CA |
| **https://libriebiblioteche.dh.unica.it/biblioteca-lussu** | `90.147.144.147:8080` | DH Sottopercorso | Biblioteca Emilio Lussu (Omeka S) | DigiCert CA |
| **https://linguistica.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Linguistica | DigiCert CA |
| **https://linguistica.dh.unica.it/emodsar** | `90.147.144.147:8000` | DH Sottopercorso | Sistema EMODSAR | DigiCert CA |
| **https://ludica.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Ludica | DigiCert CA |
| **https://musica.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Musica | DigiCert CA |
| **https://musica.dh.unica.it/labimus** | `labimus_apache_1:80` | DH Sottopercorso | Laboratorio Musicale | DigiCert CA |
| **https://musica.dh.unica.it/trajos** | `90.147.144.149:9000` | DH Sottopercorso | Trajos | DigiCert CA |
| **https://storia.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Storia | DigiCert CA |
| **https://storia.dh.unica.it/storiedigitali** | `90.147.144.145:7000` | DH Sottopercorso | Storia di Alghero | DigiCert CA |
| **https://storia.dh.unica.it/archiviodigitalerisorgimento** | `90.147.144.145:8000` | DH Sottopercorso | Progetto Antas | DigiCert CA |
| **https://storia.dh.unica.it/colonizzazioninterne** | `90.147.144.145:4000` | DH Sottopercorso | Progetto Caligola | DigiCert CA |
| **https://storia.dh.unica.it/risorse_omc** | `90.147.144.145:5000` | DH Sottopercorso | Database Cloudant | DigiCert CA |
| **https://storia.dh.unica.it/risorse** | `90.147.144.145:6000` | DH Sottopercorso | Database AS | DigiCert CA |
| **https://storia.dh.unica.it/mediawiki** | `90.147.144.156:8000` | DH Sottopercorso | Cultura Nuragica | DigiCert CA |
| **https://storia.dh.unica.it/asmsa** | `90.147.144.156:6000` | DH Sottopercorso | Progetto SCCSU | DigiCert CA |
| **https://storia.dh.unica.it/genovesi_cagliari** | `90.147.144.180:6000` | DH Sottopercorso | Rete Genovesi a Cagliari, pagina statica inclusa in /asmsa | DigiCert CA |
| **https://storia.dh.unica.it/ademprivia** | `90.147.144.156:5000` | DH Sottopercorso | Dipartimento DSAS | DigiCert CA |
| **https://storia.dh.unica.it/luoghimemoriaeuropa** | `90.147.144.180:8000` | DH Sottopercorso | Progetto Saturniana | DigiCert CA |
| **https://storia.dh.unica.it/almanaccostampasarda** | `almanaccostampasarda_mockup:80` | DH Sottopercorso | Almanacco della Sardegna, mockup (con password) | DigiCert CA |
| **https://studiericerche.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Studi e Ricerche | DigiCert CA |
| **https://ticket.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Sistema Ticketing | DigiCert CA |
| **https://xdams.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Sistema X-DAMS | DigiCert CA |
| **https://xdams.dh.unica.it/xDams** | `90.147.144.149:80` | DH Sottopercorso | X-DAMS Server | DigiCert CA |
| **https://risorse.dh.unica.it** | `90.147.144.146:7000` | DH Sottodominio | Risorse per le Digital Humanities | DigiCert CA |
| **https://archiviostorico.unica.it** | `90.147.144.162:5000` | UNICA Dominio | Archivio Storico dell'Università | DigiCert CA |
| **https://patrimonio.archiviostorico.unica.it** | `90.147.144.146:9000` | UNICA Sottodominio | Gestione del patrimonio | DigiCert CA |
| **https://patrimonio-web.archiviostorico.unica.it** | `90.147.144.146:8000` | UNICA Sottodominio | Interfaccia web patrimonio | DigiCert CA |
| **https://400.unica.it** | `90.147.144.156:7000` | UNICA Dominio | 400 anni dell'Ateneo | DigiCert CA |
| **https://aiucd2026.unica.it** | `90.147.144.180:7000` | UNICA Dominio | Convegno AIUCD 2026 (`www.` rimanda al dominio senza www) | Let's Encrypt |
| **https://humanities.unica.it** | `90.147.144.148:7000` | UNICA Dominio | Portale discipline umanistiche | DigiCert CA |
| **https://atlante.atliteg.org** | `90.147.144.147:9000` | Dominio Esterno | Atlante ATLITEG | Let's Encrypt |
| **https://www.cosmomed.org** | `90.147.144.148:9000` | Dominio Esterno | Comparative Studies Mediterranean | Let's Encrypt |
| **https://www.digitaliststor.it** | `90.147.144.162:8000` | Dominio Esterno | Istituto per la Storia Digitale | Let's Encrypt |
| **https://www.digitaliststor.it/risorse** | `90.147.144.162:6000` | Sottopercorso Esterno | Risorse DigitalIstStorico | Let's Encrypt |
| **http://www.thelastofus.it** | `90.147.144.156:5000` | Dominio Esterno | Progetto "The Last of Us": non servito, il nome non risolve nel DNS e il blocco con il backend è ignorato da nginx (nome duplicato) | SSL Disabilitato |

## Configurazioni Speciali

### Reindirizzamenti
Il file `redirect/spacagliari.conf` contiene mappature per il reindirizzamento di URL, principalmente per la gestione di progetti e sezioni del sito.

### Certificati SSL
- **DigiCert CA**: Utilizzato per i domini `dh.unica.it` e sottodomini
- **Let's Encrypt**: Utilizzato per i domini esterni (`atliteg.org`, `cosmomed.org`, `digitaliststor.it`) e per `aiucd2026.unica.it`

### Protezione Accesso
Alcuni siti hanno configurazioni per l'autenticazione HTTP Basic (attualmente commentate):
- `archiviostorico.unica.it` (configurazione presente ma disabilitata)

## Architettura Backend

Il reverse proxy gestisce il traffico inoltrando le richieste dai domini pubblici ai server backend. La mappatura completa è visibile nella colonna "Destinazione Backend" della tabella principale.

### Tipi di Backend
- **Container Docker Interni**: `dh.unica_nginx:80`, `labimus_apache_1:80`, `almanaccostampasarda_mockup:80`
- **Server Fisici Esterni**: Range IP 90.147.144.x con porte specifiche
- **Bilanciamento**: Ogni URL pubblico ha una destinazione backend dedicata

## Statistiche

- **Host pubblici**: 37 (36 in HTTPS, più `www.thelastofus.it` solo HTTP)
- **URL HTTPS**: 59, di cui 23 sottopercorsi con un backend proprio
- **Domini**: dh.unica.it (portale e 26 sottodomini), unica.it (6 host), atliteg.org, cosmomed.org, digitaliststor.it, thelastofus.it
- **Server backend**: 8 VM (90.147.144.145, .146, .147, .148, .149, .156, .162, .180) e 3 container sulla macchina del proxy

## Note Tecniche

- **Compressione gzip**: Attivata su tutti i siti
- **Client max body size**: 4000MB per upload di file grandi
- **Protezione PHP**: Blocco dell'accesso diretto a file PHP nelle directory `/files/`
- **Proxy timeout**: 900 secondi per operazioni lunghe
- **SSL redirect**: Tutti i siti reindirizzano automaticamente da HTTP a HTTPS (eccetto thelastofus.it)

---

*Documento generato dall'analisi delle configurazioni nginx il 2 ottobre 2025; tabella riallineata a `sites-enabled/` il 2 novembre 2026.*