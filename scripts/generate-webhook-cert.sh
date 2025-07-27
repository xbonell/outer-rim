#!/bin/bash

# Script to generate SSL certificate for webhook.xbonell.com

echo "Generating SSL certificate for webhook.xbonell.com..."

# Trigger certificate generation
docker exec acme-companion /app/acme.sh --issue \
  --domain webhook.xbonell.com \
  --webroot /usr/share/nginx/html \
  --email ${LETSENCRYPT_EMAIL} \
  --server letsencrypt \
  --keylength 4096 \
  --fullchain-file /etc/nginx/certs/webhook.xbonell.com.crt \
  --key-file /etc/nginx/certs/webhook.xbonell.com.key \
  --ca-file /etc/nginx/certs/webhook.xbonell.com.chain.pem \
  --dhparam-file /etc/nginx/certs/webhook.xbonell.com.dhparam.pem

echo "Certificate generation complete!" 