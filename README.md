# 🚀 Secure n8n Deployment with Caddy & Traefik

## 🌟 Overview  

This repository provides **two secure deployment templates** for **n8n** using:  
- **Caddy** – Simple, automatic SSL and reverse proxy setup  
- **Traefik** – Advanced, flexible reverse proxy with automatic SSL  

Both setups are designed to:  
- ✅ **Expose only webhooks to the public internet**  
- ✅ **Keep the n8n UI, login, and workflows private** using **Tailscale**  
- ✅ **Automatically manage SSL certificates** via Let's Encrypt  
- ✅ **Use Docker Compose for easy deployment**  

---

## 🔥 Choosing the Right Setup  

| Feature           | Caddy Template  | Traefik Template  |
|------------------|----------------|------------------|
| **Ease of Use**  | ✅ Very simple | ⚡ More flexible |
| **Auto SSL**     | ✅ Built-in    | ✅ Built-in |
| **Reverse Proxy** | ✅ Basic routing | ✅ Advanced routing & middleware |
| **Tailscale Support** | ✅ Yes | ✅ Yes |

- Use **Caddy** if you want a **quick & simple** setup.  
- Use **Traefik** if you need **more control** over routing and middleware.  

---

## 🚀 Quick Start  

### 1️⃣ Clone the repository  
```sh
git clone https://github.com/telepilotco/n8n-secure-deployment.git
cd n8n-secure-deployment/
```

### 2️⃣ Choose a setup and navigate into the folder  
```sh
cd n8n-caddy-tailscale/   # or cd n8n-traefik-tailscale/
```

### 3️⃣ Configure environment variables  
Edit `.env` to set up domains, Tailscale settings, and n8n configurations.

### 4️⃣ Deploy the setup  
```sh
sh start.sh
```

---

## 📌 Summary  

- ✅ **Secure n8n deployments with either Caddy or Traefik**  
- ✅ **Public webhooks, private admin access via Tailscale**  
- ✅ **Automatic SSL certificates with Let's Encrypt**  
- ✅ **Docker-based setup for easy management**  

---

## 🤝 Contributing  

Have improvements or want to report issues? Feel free to **open a PR or issue**.  

🔗 **Happy automating with n8n, Caddy, and Traefik!** 🚀


