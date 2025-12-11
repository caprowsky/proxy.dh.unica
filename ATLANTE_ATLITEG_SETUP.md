# Setup Guide for atlante.atliteg.org

This document provides instructions for deploying the nginx virtual host configuration for **atlante.atliteg.org**.

## Overview

- **Domain**: atlante.atliteg.org
- **Backend Server**: 90.147.144.147:9000
- **SSL Certificate**: Let's Encrypt
- **Configuration File**: `sites-enabled/atlante_atliteg.conf`

## Prerequisites

1. DNS records for `atlante.atliteg.org` must point to the proxy server IP
2. The backend application must be running on 90.147.144.147:9000
3. The backend server must be accessible from the proxy container network
4. Certbot must be installed on the host system

## Deployment Steps

### 1. Verify Configuration Files

The following files have been created:
- `/home/runner/work/proxy.dh.unica/proxy.dh.unica/sites-enabled/atlante_atliteg.conf` - nginx virtual host configuration
- `/home/runner/work/proxy.dh.unica/proxy.dh.unica/ssl-proof/atlante_atliteg/` - SSL proof directory for ACME challenge

### 2. Initial SSL Certificate Generation

Before enabling HTTPS, you need to obtain the Let's Encrypt SSL certificates. Run the following command on the host system:

```bash
# First, ensure the nginx container is running with the new configuration
cd /path/to/proxy.dh.unica
./nginx-reload.sh

# Generate the SSL certificate using certbot
sudo certbot certonly --webroot \
  -w /path/to/proxy.dh.unica/ssl-proof/atlante_atliteg \
  -d atlante.atliteg.org \
  --email your-email@example.com \
  --agree-tos \
  --non-interactive
```

**Important**: Replace `/path/to/proxy.dh.unica` with the actual path to this repository on your host system, and use a valid email address.

### 3. Verify SSL Certificate Installation

After running certbot, verify that the certificates were created:

```bash
ls -la /etc/letsencrypt/live/atlante.atliteg.org/
```

You should see:
- `fullchain.pem` - Full certificate chain
- `privkey.pem` - Private key
- `cert.pem` - Certificate
- `chain.pem` - Certificate chain

### 4. Reload nginx Configuration

Once the certificates are in place, reload nginx to apply the HTTPS configuration:

```bash
./nginx-reload.sh
```

### 5. Test the Configuration

Test that the site is accessible:

```bash
# Test HTTP redirect to HTTPS
curl -I http://atlante.atliteg.org

# Test HTTPS access
curl -I https://atlante.atliteg.org

# Verify backend connectivity
curl -I https://atlante.atliteg.org
```

## SSL Certificate Renewal

Let's Encrypt certificates expire after 90 days. The repository includes a script for automatic renewal:

```bash
# Run the certificate renewal script
./nginx-certs.sh
```

This script will:
1. Renew all Let's Encrypt certificates that are close to expiration
2. Reload the nginx configuration to apply the renewed certificates

### Automatic Renewal with Cron

To set up automatic renewal, add a cron job:

```bash
# Edit crontab
crontab -e

# Add this line to renew certificates daily at 2:30 AM
30 2 * * * /path/to/proxy.dh.unica/nginx-certs.sh >> /var/log/letsencrypt-renewal.log 2>&1
```

## Configuration Details

### Virtual Host Configuration

The configuration file `sites-enabled/atlante_atliteg.conf` includes:

1. **HTTP to HTTPS Redirect**: All HTTP traffic on port 80 is redirected to HTTPS
2. **SSL Configuration**: Uses Let's Encrypt certificates stored in `/etc/letsencrypt/live/atlante.atliteg.org/`
3. **Proxy Pass**: Forwards all requests to the backend server at `http://90.147.144.147:9000`
4. **Security Features**:
   - Blocks direct access to PHP files in upload directories
   - Sets appropriate proxy headers for backend application
   - Enables gzip compression for better performance
5. **ACME Challenge**: Supports Let's Encrypt certificate validation via `/.well-known` path

### Backend Application Requirements

The application on 90.147.144.147:9000 should:
- Accept connections from the proxy server
- Handle forwarded headers properly (X-Forwarded-For, X-Forwarded-Proto, etc.)
- Support large file uploads (up to 4000MB)
- Work with proxy timeout of 900 seconds

## Troubleshooting

### SSL Certificate Generation Fails

If certbot fails to generate certificates:

1. Ensure DNS records are properly configured and propagated
2. Verify that port 80 is accessible from the internet
3. Check that the nginx container is running and serving the `.well-known` directory
4. Ensure the `ssl-proof/atlante_atliteg/` directory has proper permissions

### Site Not Accessible

If the site is not accessible after deployment:

1. Check nginx configuration syntax:
   ```bash
   docker exec -it dhunica_proxypass nginx -t
   ```

2. Check nginx logs:
   ```bash
   docker logs dhunica_proxypass
   ```

3. Verify backend connectivity:
   ```bash
   docker exec -it dhunica_proxypass curl -I http://90.147.144.147:9000
   ```

4. Check DNS resolution:
   ```bash
   nslookup atlante.atliteg.org
   ```

### Backend Connection Issues

If the proxy cannot reach the backend:

1. Verify the backend application is running on 90.147.144.147:9000
2. Check firewall rules between the proxy and backend server
3. Ensure the backend is listening on all interfaces (0.0.0.0) or the proxy IP

## Maintenance

### Configuration Changes

To modify the nginx configuration:

1. Edit `sites-enabled/atlante_atliteg.conf`
2. Test the configuration: `docker exec -it dhunica_proxypass nginx -t`
3. Reload nginx: `./nginx-reload.sh`

### Monitoring

Monitor the site health by:
- Checking nginx access logs: `/var/log/nginx/access.log`
- Checking nginx error logs: `/var/log/nginx/error.log`
- Monitoring SSL certificate expiration: `certbot certificates`

## Support

For issues or questions:
1. Check the main documentation: `doc/SITI_WEB_REVERSE_PROXY.md`
2. Review other similar configurations in `sites-enabled/` (e.g., `cosmomed.conf`, `digitaliststor.conf`)
3. Contact the system administrator

---

**Created**: 2025-12-11
**Last Updated**: 2025-12-11
