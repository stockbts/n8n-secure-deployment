# n8n Secure Deployment with Caddy and Tailscale

This deployment provides a secure n8n workflow automation server with:
- **Public webhooks** accessible via HTTPS
- **Private admin interface** accessible only via Tailscale network
- **Automatic SSL certificates** via Let's Encrypt
- **DNS-01 challenge support** for firewalled environments

## Prerequisites

### System Requirements
- Docker and Docker Compose installed
- Public DNS domain pointing to server's public IP
- Active Tailscale account

### Tailscale Setup
1. Create a Tailscale account at https://tailscale.com/
2. Enable [HTTPS](https://tailscale.com/kb/1153/enabling-https) in Tailscale DNS settings
3. Enable [MagicDNS](https://tailscale.com/kb/1081/magicdns) in Tailscale DNS settings
4. Generate [Auth Key](https://login.tailscale.com/admin/settings/keys) (reusable key recommended)


### DNS Setup
Choose one of these options for your public domain:

#### Option A: DuckDNS (Recommended for home servers)
1. Go to https://www.duckdns.org/
2. Create a free account
3. Create a subdomain (e.g., `your-name-n8n.duckdns.org`)
4. Point it to your server's public IP
5. Get your DuckDNS token from the account page

#### Option B: Traditional DNS Provider
1. Purchase a domain from any DNS provider
2. Create an A record pointing to your server's public IP
3. Update your domain's nameservers if needed

## Architecture

### Security Model
- **Public Access**: Only `/webhook/*` and `/webhook-test/*` endpoints are exposed to the internet
- **Private Access**: n8n admin UI, login, and workflows are only accessible via Tailscale private network
- **SSL/TLS**: Automatic certificate management via Let's Encrypt for public domains and Tailscale for private domains

### Services
- **n8n**: Workflow automation engine
- **Caddy**: Reverse proxy with automatic SSL
- **Tailscale**: Private networking service

## Quick Start

### 1. Clone and Setup
```bash
git clone <this-repo>
cd n8n-secure-deployment/n8n-caddy-tailscale
cp .env.example .env
```

### 2. Configure Environment
Edit `.env` file with your values:
```bash
# Your public domain for webhooks
PUBLIC_DOMAIN=your-domain.duckdns.org

# Your Tailscale domain (get from: tailscale status)
TAILSCALE_DOMAIN=your-hostname.your-tailnet.ts.net

# Your email for SSL certificates
USER_EMAIL=your-email@example.com

# Your Tailscale auth key
TAILSCALE_AUTH_KEY=your-tailscale-auth-key-here

# DuckDNS token (if using DuckDNS)
DUCKDNS_TOKEN=your-duckdns-token-here
```

### 3. Start Services
```bash
chmod +x start.sh
./start.sh
```

### 4. Generate SSL Certificates (if behind firewall)
If you're behind a firewall that blocks HTTP-01 challenges:
```bash
chmod +x get-ssl-cert.sh
./get-ssl-cert.sh
```

### 5. Access n8n
- **Private Admin**: https://your-hostname.your-tailnet.ts.net/
- **Public Webhooks**: https://your-domain.duckdns.org/webhook/*

## SSL Certificate Options

### Automatic (Default)
Caddy will automatically obtain SSL certificates via HTTP-01 challenge. This works if:
- Your server is publicly accessible on ports 80/443
- No firewall blocks Let's Encrypt verification

### Manual (Firewalled Environments)
If automatic SSL fails, use DNS-01 challenge:
1. Configure `DUCKDNS_TOKEN` in `.env`
2. Run `./get-ssl-cert.sh`
3. Certificates will be saved to `./ssl/` directory

## Management Commands

### Service Control
```bash
# Start services
./start.sh

# Stop services
./stop.sh

# View logs
./logs.sh

# Restart specific service
docker-compose restart caddy
docker-compose restart n8n
docker-compose restart tailscale
```

### Troubleshooting
```bash
# Check service status
docker-compose ps

# Check Tailscale status
docker exec -it tailscale tailscale status

# View specific service logs
docker logs -f caddy
docker logs -f n8n
docker logs -f tailscale

# Test webhook access
curl -I https://your-domain.duckdns.org/webhook/test

# Test private access (from Tailscale network)
curl -I https://your-hostname.your-tailnet.ts.net/
```

## Security Features

### Access Control
- **Webhooks**: Public access via `https://PUBLIC_DOMAIN/webhook/*`
- **Admin UI**: Private access via `https://TAILSCALE_DOMAIN/`
- **All other endpoints**: Blocked with 403 Forbidden

### Network Isolation
- n8n runs in isolated internal network
- Only reverse proxy bridges internal and external networks
- Tailscale provides encrypted private network access

### SSL/TLS
- Let's Encrypt certificates for public domains
- Tailscale certificates for private domains (.ts.net)
- Automatic certificate renewal

## Common Issues

### SSL Certificate Errors
- **Cause**: Tailscale HTTPS/MagicDNS not enabled
- **Solution**: Enable in Tailscale DNS settings

### Tailscale Connection Issues
- **Cause**: Invalid auth key or network connectivity
- **Solution**: Verify auth key and check `docker logs tailscale`

### Service Not Starting
- **Cause**: Configuration errors
- **Solution**: Check `docker-compose logs` and verify `.env` file

### Webhook Access Issues
- **Cause**: DNS or firewall configuration
- **Solution**: Verify public domain DNS and firewall rules

