# Copilot Instructions for DH.UNICA Reverse Proxy

## Project Overview
This is a Docker-based nginx reverse proxy managing 30+ websites for the University of Cagliari's Digital Humanities infrastructure. The proxy handles both internal Docker services and external backend servers across multiple IP addresses.

## Architecture Patterns

### Service Categories
- **DH Subdomains**: `*.dh.unica.it` → mostly proxy to `dh.unica_nginx:80` container
- **UNICA Domains**: `*.unica.it` → proxy to specific external IPs (90.147.144.x)  
- **External Domains**: `cosmomed.org`, `digitaliststor.it`, `thelastofus.it`

### Configuration Naming Convention
Files in `sites-enabled/` follow strict patterns:
- `dhunica.conf` - main domain
- `{subdomain}_dhunica.conf` - DH subdomains (e.g., `storia_dhunica.conf`)
- `{domain}.conf` - external domains (e.g., `cosmomed.conf`)
- `{subdomain}_{parent}.conf` - nested subdomains (e.g., `patrimonio_archiviostorico.conf`)

### Standard nginx Server Block Pattern
Every `.conf` file follows this structure:
```nginx
server {
    listen 80;
    server_name example.domain.it;
    return 301 https://example.domain.it$request_uri;  # HTTP → HTTPS redirect
}

server {
    listen 443 ssl;
    server_name example.domain.it;
    
    # SSL certificates (DigiCert for *.unica.it, Let's Encrypt for external)
    ssl_certificate /path/to/cert;
    ssl_certificate_key /path/to/key;
    
    # Standard location blocks (see below)
}
```

### Location Block Patterns
- `/.well-known` → SSL proof directory for certificate validation
- `/` → main proxy_pass with standard headers and gzip
- `/files/.*.php$` → security block (deny all PHP in uploads)
- Custom paths → specific backend services (see `storia_dhunica.conf` for complex routing)

### SSL Certificate Strategy
- **DigiCert**: `/etc/digicertca/live/dh.unica.it/` for all `*.unica.it` domains
  (commercial certificates, renewed manually via the university - certbot is not involved)
- **Let's Encrypt**: `/etc/letsencrypt/live/{domain}/` for external domains
  (renewed automatically, see below)
- **SSL Proof**: Organized by domain in `/var/www/ssl-proof/{domain}/`, bind-mounted
  into the container at `/var/www/ssl-proof` for the ACME http-01 challenge

### Automatic Renewal (two parts, both required)
1. `snap.certbot.renew.timer` runs `certbot renew` twice a day (host systemd)
2. `/etc/letsencrypt/renewal-hooks/deploy/00-reload-dhunica-proxy.sh` reloads nginx
   inside the container **after** each renewal - source of truth is
   `scripts/certbot-deploy-hook.sh` in this repo

**Never assume a renewed certificate is being served.** Nginx reads certificates at
startup and keeps them in memory: without part 2 the container serves the old
certificate until it expires, which is exactly what took down `atlante.atliteg.org`
in September 2026. When touching certificates, always compare what is on disk with
what is actually served (`openssl s_client`) - see the README troubleshooting section.

## Backend Infrastructure

### Internal Docker Services
- `dh.unica_nginx:80` - Primary DH platform backend
- `labimus_apache_1:80` - Music laboratory service

### External Backend Mapping
Key IP ranges and their services:
- `90.147.144.145` - Glossari (8080), Storia projects (4000-8000)
- `90.147.144.146` - Patrimonio services (7000-9000) 
- `90.147.144.147` - EMODSAR (8000), Phaidra (9000)
- `90.147.144.148` - GIS (80), Humanities (7000), CoSMoMed (9000)
- `90.147.144.149` - X-DAMS (80), Cemetery (9000)
- `90.147.144.156` - Multiple story services (5000-8000)
- `90.147.144.162` - Archivio Storico (5000), DigitalIstStorico (6000, 8000)

## Development Workflows

### Configuration Changes
```bash
# Add new site: Create .conf in sites-enabled/ following naming patterns
# Reload configuration without downtime
./nginx-reload.sh

# Full restart (for major changes)
./nginx-restart.sh

# Complete rebuild
./nginx-reset.sh
```

### SSL Certificate Management
```bash
# Renewal is automatic (certbot timer + deploy hook). These are for manual work:

# Force a renewal now, then reload
./nginx-certs.sh

# Dry-run the whole chain, deploy hooks included
sudo certbot renew --dry-run --run-deploy-hooks

# Expiry of every virtual host (disk + actually served)
python3 scripts/check_ssl_expiry.py

# (Re)install the deploy hook, e.g. after a server reinstall
./scripts/install-certbot-deploy-hook.sh              # via sudo
./scripts/install-certbot-deploy-hook.sh --via-docker # docker group is enough

# SSL proof directories must exist in ssl-proof/{domain}/
mkdir -p ssl-proof/new-domain/
```

Note: `sudo` on the proxy host prompts for a password, but the `dhwp` user is in the
`docker` group and the container mounts `/etc/letsencrypt` while running as root -
so `docker exec -i dhunica_proxypass sh -c 'cat > /etc/...'` writes as root on the
host when sudo is unavailable.

### Authentication Setup
- HTTP Basic Auth files in `htpassword/.htpasswd_{site}`
- Enable in site config: `auth_basic_user_file /etc/password_custom/.htpasswd_{site};`

## Critical Configuration Standards

### Proxy Headers (Required for all locations)
```nginx
proxy_set_header Host $host;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Port $server_port;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

### Performance Settings (Standard across all sites)
```nginx
proxy_read_timeout 900s;
client_max_body_size 4000M;  # Large file uploads
gzip on;
gzip_min_length 1100;
gzip_types text/plain application/javascript application/x-javascript text/xml text/css image/svg+xml;
```

### Security Patterns
- Always include `/files/.*.php$` deny block
- Use `/.well-known` for ACME challenges
- External domains require dedicated SSL proof directories

## Network Dependencies
- External networks: `dhunica_default`, `dhunica_laravel_default`
- Container links to: `dh.unica_nginx`, `dhunica_laravel_default`
- Port binding: Host 80/443 → Container 80/443

## Debugging
- Check container logs: `docker logs dhunica_proxypass`  
- Test nginx config: `docker exec dhunica_proxypass nginx -t`
- Monitor backends: Each backend IP:port must be accessible from container network