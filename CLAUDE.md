# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains secure deployment templates for n8n workflow automation using Docker Compose. It provides two different reverse proxy solutions:

1. **Caddy Template** (`n8n-caddy-tailscale/`) - Simple, automatic SSL setup
2. **Traefik Template** (`n8n-traefik-tailscale/`) - Advanced routing with middleware support

Both templates implement the same security model: **public webhooks accessible via public domain**, **private n8n UI accessible only via Tailscale network**.

## Architecture

### Security Model
- **Public Access**: Only `/webhook/*` and `/webhook-test/*` endpoints are exposed to the internet
- **Private Access**: n8n admin UI, login, and workflows are only accessible via Tailscale private network
- **SSL/TLS**: Automatic certificate management via Let's Encrypt for public domains and Tailscale for private domains

### Service Components
- **n8n**: Workflow automation engine (container: `n8n`)
- **Reverse Proxy**: Either Caddy (`caddy`) or Traefik (`traefik`)
- **Tailscale**: Private networking service (`tailscale`)

### Network Architecture
- **Internal Network**: n8n communicates with reverse proxy
- **Proxy Network**: Reverse proxy handles external connections
- **Host Network**: Tailscale requires host networking for VPN functionality

## Common Commands

### Deployment Management
```bash
# Start services (both templates)
cd n8n-caddy-tailscale/     # or n8n-traefik-tailscale/
sh start.sh

# Stop services
sh stop.sh

# View logs
sh logs.sh

# Restart services
docker-compose restart

# View specific service logs
docker logs -f caddy        # or traefik
docker logs -f n8n
docker logs -f tailscale
```

### Environment Setup
```bash
# Copy and configure environment file
cp .env.example .env
# Edit .env with your domains, email, and Tailscale auth key
```

### Troubleshooting Commands
```bash
# Check Tailscale status
docker exec -it tailscale tailscale status

# Test connectivity to Tailscale domain
ping n8n-server-caddy.[YOUR_TAILNET].ts.net

# Check SSL certificate status
docker logs caddy | grep -i certificate
docker logs traefik | grep -i certificate
```

## Configuration Files

### Environment Variables (.env)
Required environment variables for both templates:
- `PUBLIC_DOMAIN`: Public domain for webhooks (e.g., n8n.yourdomain.com)
- `TAILSCALE_DOMAIN`: Private Tailscale domain (e.g., n8n-server-caddy.[YOUR_TAILNET].ts.net)
- `TAILSCALE_AUTH_KEY`: Tailscale authentication key
- `USER_EMAIL`: Email for Let's Encrypt SSL certificates
- `N8N_HOST`, `N8N_PORT`, `WEBHOOK_URL`, `GENERIC_TIMEZONE`: n8n configuration

### Caddy Template
- `Caddyfile`: Reverse proxy configuration with automatic SSL
- `docker-compose.yml`: Service definitions with Caddy

### Traefik Template
- `traefik.yml`: Traefik configuration file
- `docker-compose.yml`: Service definitions with Traefik labels

## Prerequisites

### System Requirements
- Docker and Docker Compose installed
- Public DNS domain pointing to server's public IP
- Active Tailscale account

### Tailscale Setup
Required Tailscale configuration:
- Enable [HTTPS](https://tailscale.com/kb/1153/enabling-https) in Tailscale DNS settings
- Enable [MagicDNS](https://tailscale.com/kb/1081/magicdns) in Tailscale DNS settings
- Generate [Auth Key](https://login.tailscale.com/admin/settings/keys)

## Security Features

### Access Control
- Webhooks: Public access via `https://PUBLIC_DOMAIN/webhook/*`
- Admin UI: Private access via `https://TAILSCALE_DOMAIN/`
- All other endpoints: Blocked with 403 Forbidden

### SSL/TLS
- Let's Encrypt certificates for public domains
- Tailscale certificates for private domains (.ts.net)
- Automatic certificate renewal

### Network Isolation
- n8n runs in isolated internal network
- Only reverse proxy bridges internal and external networks
- Tailscale provides encrypted private network access

## Development Notes

### File Structure
```
n8n-secure-deployment/
├── README.md
├── n8n-caddy-tailscale/
│   ├── docker-compose.yml
│   ├── Caddyfile
│   ├── .env.example
│   ├── start.sh
│   ├── stop.sh
│   └── logs.sh
└── n8n-traefik-tailscale/
    ├── docker-compose.yml
    ├── traefik.yml
    ├── .env.example
    ├── start.sh
    ├── stop.sh
    └── logs.sh
```

### Common Issues
- **SSL Certificate Errors**: Check Tailscale HTTPS/MagicDNS settings
- **Tailscale Connection Issues**: Verify auth key and network connectivity
- **Service Not Starting**: Check Docker logs and environment variables
- **Webhook Access Issues**: Verify public domain DNS configuration

### Template Differences
- **Caddy**: Simpler configuration, single Caddyfile
- **Traefik**: More complex but flexible, uses labels and separate config file
- Both use identical security model and environment variables