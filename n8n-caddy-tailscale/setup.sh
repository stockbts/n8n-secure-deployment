#!/bin/bash

# n8n Secure Deployment Setup Script
# This script helps you set up the n8n secure deployment

set -e

echo "🚀 n8n Secure Deployment Setup"
echo "================================"
echo

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker and Docker Compose first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed!"
    echo "Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo

# Check if .env file exists
if [ ! -f .env ]; then
    echo "📋 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created"
    echo
    echo "⚙️  IMPORTANT: Please edit the .env file with your configuration:"
    echo "   - Set your PUBLIC_DOMAIN (e.g., your-domain.duckdns.org)"
    echo "   - Set your TAILSCALE_DOMAIN (get from: tailscale status)"
    echo "   - Set your USER_EMAIL for SSL certificates"
    echo "   - Set your TAILSCALE_AUTH_KEY (get from Tailscale admin)"
    echo "   - Set your DUCKDNS_TOKEN if using DuckDNS"
    echo
    echo "   Edit with: nano .env"
    echo
    read -p "Press Enter after you've configured the .env file..."
else
    echo "✅ .env file already exists"
fi

echo

# Validate .env file
echo "🔍 Validating .env configuration..."

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

# Check required variables
missing_vars=()

if [ -z "$PUBLIC_DOMAIN" ] || [ "$PUBLIC_DOMAIN" = "your-domain.duckdns.org" ]; then
    missing_vars+=("PUBLIC_DOMAIN")
fi

if [ -z "$TAILSCALE_DOMAIN" ] || [ "$TAILSCALE_DOMAIN" = "your-hostname.your-tailnet.ts.net" ]; then
    missing_vars+=("TAILSCALE_DOMAIN")
fi

if [ -z "$USER_EMAIL" ] || [ "$USER_EMAIL" = "your-email@example.com" ]; then
    missing_vars+=("USER_EMAIL")
fi

if [ -z "$TAILSCALE_AUTH_KEY" ] || [ "$TAILSCALE_AUTH_KEY" = "your-tailscale-auth-key-here" ]; then
    missing_vars+=("TAILSCALE_AUTH_KEY")
fi

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "❌ Missing or unconfigured environment variables:"
    for var in "${missing_vars[@]}"; do
        echo "   - $var"
    done
    echo
    echo "Please edit .env file and set these variables."
    echo "Edit with: nano .env"
    exit 1
fi

echo "✅ Environment configuration validated"
echo

# Check if Tailscale prerequisites are met
echo "🔍 Checking Tailscale prerequisites..."
echo "   Make sure you have:"
echo "   - ✅ Tailscale account created"
echo "   - ✅ HTTPS enabled in Tailscale DNS settings"
echo "   - ✅ MagicDNS enabled in Tailscale DNS settings"
echo "   - ✅ Auth key generated and added to .env"
echo

# Check DNS resolution
echo "🔍 Checking DNS resolution..."
if nslookup "$PUBLIC_DOMAIN" > /dev/null 2>&1; then
    echo "✅ $PUBLIC_DOMAIN resolves successfully"
else
    echo "⚠️  Warning: $PUBLIC_DOMAIN does not resolve"
    echo "   Make sure your domain points to this server's public IP"
fi

echo

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x start.sh stop.sh logs.sh get-ssl-cert.sh
echo "✅ Scripts are now executable"
echo

# Create ssl directory
echo "📁 Creating SSL directory..."
mkdir -p ssl
echo "✅ SSL directory created"
echo

# Final instructions
echo "🎉 Setup complete!"
echo
echo "Next steps:"
echo "1. Start the services: ./start.sh"
echo "2. Check logs: ./logs.sh"
echo "3. If behind firewall, generate SSL certificates: ./get-ssl-cert.sh"
echo
echo "Access URLs:"
echo "- Private Admin (Tailscale): https://$TAILSCALE_DOMAIN/"
echo "- Public Webhooks: https://$PUBLIC_DOMAIN/webhook/*"
echo
echo "For troubleshooting, check the README.md file."
echo "🚀 Happy automating with n8n!"