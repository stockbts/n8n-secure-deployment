#!/bin/bash

# DuckDNS SSL Certificate Script
# This script uses acme.sh to get SSL certificates via DNS-01 challenge

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "Error: .env file not found!"
    echo "Please copy .env.example to .env and configure your settings."
    exit 1
fi

# Check required variables
if [ -z "$DUCKDNS_TOKEN" ]; then
    echo "Error: DUCKDNS_TOKEN not set in .env file!"
    exit 1
fi

if [ -z "$PUBLIC_DOMAIN" ]; then
    echo "Error: PUBLIC_DOMAIN not set in .env file!"
    exit 1
fi

# Install acme.sh if not present
if [ ! -f ~/.acme.sh/acme.sh ]; then
    echo "Installing acme.sh..."
    curl https://get.acme.sh | sh
fi

# Export DuckDNS token
export DuckDNS_Token="$DUCKDNS_TOKEN"

# Get certificate using DNS-01 challenge
~/.acme.sh/acme.sh --issue --dns dns_duckdns -d "$PUBLIC_DOMAIN"

# Copy certificates to Caddy directory
mkdir -p ./ssl
~/.acme.sh/acme.sh --install-cert -d "$PUBLIC_DOMAIN" \
    --key-file ./ssl/key.pem \
    --fullchain-file ./ssl/cert.pem

echo "SSL certificates generated for $PUBLIC_DOMAIN!"
echo "Certificates saved to ./ssl/"
echo "Update your Caddyfile to use these certificates:"
echo "tls /ssl/cert.pem /ssl/key.pem"