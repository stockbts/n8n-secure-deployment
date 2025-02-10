# n8n + Traefik + Tailscale: Secure Automation with Private UI & Public Webhooks

(How to Securely Host n8n with Traefik Reverse Proxy & Tailscale Wireguard network)

## 🌟 Introduction

This setup is designed for **secure, automated workflow execution** with **n8n**, **Traefik**, and **Tailscale**. It ensures that **only webhooks are publicly accessible**, while keeping the **n8n UI, login, and workflows private** within a Tailscale network.

## Prerequisites

Docker and Docker Compose installed on your system. You should also have public DNS name available and point it to public IP Address of your n8n server.
An active Tailscale account. You will need to do following things additionally:
- Enable [HTTPs](https://tailscale.com/kb/1153/enabling-https) and [MagicDNS](https://tailscale.com/kb/1081/magicdns) in Tailscale [DNS config](https://login.tailscale.com/admin/dns) 
- [Add Auth Key](https://login.tailscale.com/admin/settings/keys)


### 🚀 Problems This Setup Solves:
- **Public exposure of n8n UI**: Many self-hosted n8n setups leave the admin panel exposed to the internet, increasing security risks.
- **Secure webhook handling**: Some automation workflows need public webhooks but shouldn't expose the entire n8n instance.
- **Complex SSL management**: Manually setting up and renewing SSL certificates can be a hassle.
- **Lack of private networking**: Running n8n in a secure, isolated environment without a VPN can be challenging.

### 🎯 Suitable Use-Cases:
- **Teams using Tailscale for internal services**: Securely access the n8n UI only within your private Tailscale network.
- **Users requiring public webhooks**: Expose only `/webhook/*` endpoints while keeping everything else private.
- **Developers and businesses automating workflows**: Run n8n with confidence, knowing that the admin panel is protected.
- **Self-hosted automation without exposing infrastructure**: No need for complex VPN setups or firewall rules.

With this setup, you can leverage **Tailscale for private networking**, **Traefik for automated SSL and reverse proxying**, and **n8n for powerful workflow automation** in a **secure and manageable** way.

---

## 📂 Folder Structure
```
n8n-traefik-tailscale/
│-- docker-compose.yml
│-- traefik.yml
│-- .env  # Store environment variables here
│-- logs.sh
│-- start.sh
│-- stop.sh
│-- README.md
```

---

## 🚀 Quick Start

### 1️⃣ Clone this repository
```sh
git clone https://github.com/telepilotco/n8n-secure-deployment.git
cd n8n-secure-deployment/n8n-traefik-tailscale/
```

### 2️⃣ Configure `.env`
Create and edit a `.env` file:
```ini
# n8n Configuration
N8N_HOST=0.0.0.0
N8N_PORT=5678

# Public Domain for Webhooks
PUBLIC_DOMAIN=n8n.yourdomain.com

# Private Tailscale Domain
TAILSCALE_DOMAIN=n8n-server-traefik.[YOUR_TAILNET].ts.net

WEBHOOK_URL=https://n8n.yourdomain.com
GENERIC_TIMEZONE=UTC

# Tailscale Authentication Key (Get from https://login.tailscale.com/admin/settings/keys)
TAILSCALE_AUTH_KEY=[YOUR_TAILSCALE_KEY]

#Email for automatic SSL Certificate management via Let's Encrypt
USER_EMAIL=example@email.com
```

### 3️⃣ Adjust `traefik.yml`
Email for Let's Encrypt SSL Certificate management needs to be adjusted in `certificatesResolvers.letsencrypt.acme.email` and Tailscale domain/servername changed in `http.routers.routertailscale.rule`.

### 4️⃣ Start the Containers
```sh
sh start.sh
```

### 5️⃣ Access n8n Securely
- **Public Webhooks:** `https://n8n.yourdomain.com/webhook/...`
- **Admin & Workflows (Private):** `https://n8n-server-traefik.[YOUR_TAILNET].ts.net/`

---

## 📜 Configuration Files

### **docker-compose.yml**
This file defines deployment of n8n, Traefik and Tailscale services and networks. 
Configration includes:

1. Tailscale service: Configures Tailscale to be run in docker environment with private Auth Key and enables secure communication between Tailscale private network and other Docker services

2. Traefik webserver / rewrite proxy: Sets up Traefik to run according to configuration specified in trafik.yml, exposing ports 80 and 443. Tailnet SSL certificates are fetched via shared Tailscale socket file

3. n8n service: Sets up n8n to run behind Caddy reverse proxy, and configures webhooks to be accessible only via public domain

### **traefik.yml**
Handles SSL, reverse proxy, and access control.

```yaml
api:
  dashboard: true

entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

providers:
  docker:
    exposedByDefault: false

certificatesResolvers:
  myresolver:
        tailscale: {}
  letsencrypt:
    acme:
      email: [USER_EMAIL]
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web

http:
  routers:
    routertailscale:
      service: "myservice"
      rule: "Host(`n8n-server-traefik.[YOUR_TAILNET].ts.net`) && Path(`/tailscale`)"
      tls:
        certResolver: tailscale

  services:
    myservice:
      loadBalancer:
        servers:
         - url: "http://localhost:6060"
```

---

## 🔄 Managing the Setup

### Restart Containers
```sh
docker-compose restart
```

### Check Logs
```sh
sh logs.sh
```

### Stop the Setup
```sh
sh stop.sh
```

---

## 🛡️ Security Notes
- **Only webhooks are exposed to the public domain (`n8n.yourdomain.com`).**
- **Admin, workflows, and login are private within Tailscale (`n8n-server.ts.net`).**
- **Tailscale provides a secure, encrypted tunnel for private access.**
- **Traefik auto-renews SSL certificates using Let's Encrypt.**

---

## 💡 Troubleshooting

### SSL Not Issued for `.ts.net`
Ensure your Tailscale node is reachable publicly for HTTP-01 validation:
```sh
tailscale funnel 443
```
Or use DNS-01 validation with a provider like Cloudflare.

### Cannot Access n8n UI
Ensure your device is connected to Tailscale and try:
```sh
ping n8n-server.ts.net
```

### Check Tailscale Status
```sh
docker exec -it tailscale tailscale status
```

### Check traefik logs
```sh
docker logs -f traefik
```

If setup does not work and you see following error message in traefik logs, restart everything by running `sh stop.sh && sh start.sh`:
```
ubuntu@n8n-server-caddy:~/n8n-secure-deployment/n8n-traefik-tailscale$ docker logs -f traefik
2025-02-09T15:38:03Z ERR Unable to fetch certificate for domain "n8n-server-traefik.[YOUR_TAILNET].ts.net" error="Get \"http://local-tailscaled.sock/localapi/v0/cert/n8n-server-traefik.[YOUR_TAILNET].ts.net?type=pair\": dial unix /var/run/tailscale/tailscaled.sock: connect: connection refused" providerName=myresolver.tailscale
```

---

## 📌 Summary
✅ **n8n is secure behind Tailscale**  
✅ **Webhooks are publicly accessible with SSL**  
✅ **Admin panel is only available inside Tailscale**  
✅ **Traefik automatically handles SSL certificates**  

🚀 Enjoy secure and private automation with n8n, Traefik, and Tailscale!

