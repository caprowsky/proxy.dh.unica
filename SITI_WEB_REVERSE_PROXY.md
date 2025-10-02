# Analisi Reverse Proxy DH.UNICA

## Panoramica del Progetto

Questo progetto implementa un reverse proxy bassu su **nginx** che gestisce il traffico per più di 30 siti web dell'Università di Cagliari, principalmente focalizzati sulle Digital Humanities. Il reverse proxy è containerizzato con Docker e gestisce sia il traffico HTTP che HTTPS, con certificati SSL configurati.

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
| **https://archivistica.dh.unica.it/phaidra** | `90.147.144.147:9000` | DH Sottopercorso | Repository Phaidra | DigiCert CA |
| **https://archivistica.dh.unica.it/patrimonio** | `90.147.144.146:8000` | DH Sottopercorso | Sistema Patrimonio | DigiCert CA |
| **https://arte.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Arte | DigiCert CA |
| **https://artemusei.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Arte e Musei | DigiCert CA |
| **https://asuca.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto ASUCA | DigiCert CA |
| **https://cinema.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Cinema | DigiCert CA |
| **https://doc.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Documentazione | DigiCert CA |
| **https://docs.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Documentazione | DigiCert CA |
| **https://editoria.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Editoria | DigiCert CA |
| **https://filologia.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Filologia | DigiCert CA |
| **https://geo.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Geografia | DigiCert CA |
| **https://geo.dh.unica.it/giscagliari** | `90.147.144.148:80` | DH Sottopercorso | GIS Cagliari | DigiCert CA |
| **https://geografia.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Geografia | DigiCert CA |
| **https://glossari.dh.unica.it** | `90.147.144.145:8080` | DH Sottodominio | Sistema Glossari | DigiCert CA |
| **https://letteratura.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Letteratura | DigiCert CA |
| **https://libriebiblioteche.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Libri e Biblioteche | DigiCert CA |
| **https://linguistica.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Linguistica | DigiCert CA |
| **https://linguistica.dh.unica.it/emodsar** | `90.147.144.147:8000` | DH Sottopercorso | Sistema EMODSAR | DigiCert CA |
| **https://ludica.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Ludica | DigiCert CA |
| **https://musica.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Musica | DigiCert CA |
| **https://musica.dh.unica.it/labimus** | `labimus_apache_1:80` | DH Sottopercorso | Laboratorio Musicale | DigiCert CA |
| **https://musica.dh.unica.it/cemetery** | `90.147.144.149:9000` | DH Sottopercorso | Progetto Cemetery | DigiCert CA |
| **https://storia.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Progetto Storia | DigiCert CA |
| **https://storia.dh.unica.it/storiedigitali** | `90.147.144.145:7000` | DH Sottopercorso | Storia di Alghero | DigiCert CA |
| **https://storia.dh.unica.it/archiviodigitalerisorgimento** | `90.147.144.145:8000` | DH Sottopercorso | Progetto Antas | DigiCert CA |
| **https://storia.dh.unica.it/colonizzazioninterne** | `90.147.144.145:4000` | DH Sottopercorso | Progetto Caligola | DigiCert CA |
| **https://storia.dh.unica.it/risorse_omc** | `90.147.144.145:5000` | DH Sottopercorso | Database Cloudant | DigiCert CA |
| **https://storia.dh.unica.it/risorse** | `90.147.144.145:6000` | DH Sottopercorso | Database AS | DigiCert CA |
| **https://storia.dh.unica.it/mediawiki** | `90.147.144.156:8000` | DH Sottopercorso | Cultura Nuragica | DigiCert CA |
| **https://storia.dh.unica.it/asmsa** | `90.147.144.156:6000` | DH Sottopercorso | Progetto SCCSU | DigiCert CA |
| **https://storia.dh.unica.it/ademprivia** | `90.147.144.156:5000` | DH Sottopercorso | Dipartimento DSAS | DigiCert CA |
| **https://storia.dh.unica.it/luoghimemoriaeuropa** | `90.147.144.180:8000` | DH Sottopercorso | Progetto Saturniana | DigiCert CA |
| **https://studiericerche.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Studi e Ricerche | DigiCert CA |
| **https://ticket.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Sistema Ticketing | DigiCert CA |
| **https://xdams.dh.unica.it** | `dh.unica_nginx:80` | DH Sottodominio | Sistema X-DAMS | DigiCert CA |
| **https://xdams.dh.unica.it/xdams** | `90.147.144.149:80` | DH Sottopercorso | X-DAMS Server | DigiCert CA |
| **https://risorse.dh.unica.it** | `90.147.144.146:7000` | DH Sottodominio | Risorse per le Digital Humanities | DigiCert CA |
| **https://archiviostorico.unica.it** | `90.147.144.162:5000` | UNICA Dominio | Archivio Storico dell'Università | DigiCert CA |
| **https://patrimonio.archiviostorico.unica.it** | `90.147.144.146:9000` | UNICA Sottodominio | Gestione del patrimonio | DigiCert CA |
| **https://patrimonio-web.archiviostorico.unica.it** | `90.147.144.146:8000` | UNICA Sottodominio | Interfaccia web patrimonio | DigiCert CA |
| **https://400.unica.it** | `90.147.144.156:7000` | UNICA Dominio | 400 anni dell'Ateneo | DigiCert CA |
| **https://humanities.unica.it** | `90.147.144.148:7000` | UNICA Dominio | Portale discipline umanistiche | DigiCert CA |
| **https://www.cosmomed.org** | `90.147.144.148:9000` | Dominio Esterno | Comparative Studies Mediterranean | Let's Encrypt |
| **https://www.digitaliststor.it** | `90.147.144.162:8000` | Dominio Esterno | Istituto per la Storia Digitale | Let's Encrypt |
| **https://www.digitaliststor.it/risorse** | `90.147.144.162:6000` | Sottopercorso Esterno | Risorse DigitalIstStorico | Let's Encrypt |
| **http://www.thelastofus.it** | `90.147.144.156:5000` | Dominio Esterno | Progetto "The Last of Us" | SSL Disabilitato |

## Configurazioni Speciali

### Reindirizzamenti
Il file `redirect/spacagliari.conf` contiene mappature per il reindirizzamento di URL, principalmente per la gestione di progetti e sezioni del sito.

### Certificati SSL
- **DigiCert CA**: Utilizzato per i domini `dh.unica.it` e sottodomini
- **Let's Encrypt**: Utilizzato per domini esterni come `cosmomed.org` e `digitaliststor.it`

### Protezione Accesso
Alcuni siti hanno configurazioni per l'autenticazione HTTP Basic (attualmente commentate):
- `archiviostorico.unica.it` (configurazione presente ma disabilitata)

## Server Backend

### Server Interni Docker
- `dh.unica_nginx:80` - Server principale per tutti i sottoprogetti DH
- `labimus_apache_1:80` - Server Apache per il laboratorio musicale

### Server Esterni (IP: 90.147.144.x)
- **90.147.144.145**: Glossari (8080), Alghero (7000), Antas (8000), Caligola (4000), Cloudant (5000), DBAS (6000)
- **90.147.144.146**: Patrimonio Web (8000), Patrimonio (9000), Risorse (7000)
- **90.147.144.147**: EMODSAR (8000), Phaidra (9000)
- **90.147.144.148**: GIS Cagliari (80), Humanities (7000), CoSMoMed (9000)
- **90.147.144.149**: Cemetery (9000), X-DAMS (80)
- **90.147.144.156**: 400 Anni (7000), The Last of Us (5000), SCCSU (6000), Nuragic (8000)
- **90.147.144.162**: ArchivioStorico (5000), DigitalIstStorico main (8000), DigitalIstStorico risorse (6000)
- **90.147.144.180**: Saturniana (8000)

## Statistiche

- **Totale siti web**: 33+ siti web distinti
- **Domini principali**: 6 (dh.unica.it, unica.it, cosmomed.org, digitaliststor.it, thelastofus.it)
- **Sottoprogetti DH**: 23 sottoprogetti del dominio dh.unica.it
- **Server backend**: 10 server fisici/virtuali distinti

## Note Tecniche

- **Compressione gzip**: Attivata su tutti i siti
- **Client max body size**: 4000MB per upload di file grandi
- **Protezione PHP**: Blocco dell'accesso diretto a file PHP nelle directory `/files/`
- **Proxy timeout**: 900 secondi per operazioni lunghe
- **SSL redirect**: Tutti i siti reindirizzano automaticamente da HTTP a HTTPS (eccetto thelastofus.it)

---

*Documento generato automaticamente dall'analisi delle configurazioni nginx - Data: 2 ottobre 2025*