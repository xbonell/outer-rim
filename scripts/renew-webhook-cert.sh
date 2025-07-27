#!/bin/bash

# Automated SSL certificate renewal for webhook.xbonell.com

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/webhook-cert-renewal.log"
CERTS_DIR="$SCRIPT_DIR/../nginx/certs"
DOMAIN_DIR="$CERTS_DIR/_test_webhook.xbonell.com"

# Load environment variables
if [ -f "$SCRIPT_DIR/../.env" ]; then
    source "$SCRIPT_DIR/../.env"
else
    echo "Error: .env file not found" | tee -a "$LOG_FILE"
    exit 1
fi

echo "$(date): Starting webhook certificate renewal check..." | tee -a "$LOG_FILE"

# Ensure domain directory exists
mkdir -p "$DOMAIN_DIR"

# Function to create symbolic links
create_symlinks() {
    echo "$(date): Creating symbolic links..." | tee -a "$LOG_FILE"
    
    # Create symbolic links for webhook.xbonell.com
    ln -sf ./_test_webhook.xbonell.com/fullchain.pem "$CERTS_DIR/webhook.xbonell.com.crt"
    ln -sf ./_test_webhook.xbonell.com/key.pem "$CERTS_DIR/webhook.xbonell.com.key"
    ln -sf ./_test_webhook.xbonell.com/chain.pem "$CERTS_DIR/webhook.xbonell.com.chain.pem"
    ln -sf ./dhparam.pem "$CERTS_DIR/webhook.xbonell.com.dhparam.pem"
    
    echo "$(date): Symbolic links created successfully" | tee -a "$LOG_FILE"
}

# Check if certificate exists and is valid
if [ -f "$DOMAIN_DIR/fullchain.pem" ]; then
    # Check certificate expiration (renew if less than 30 days)
    EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$DOMAIN_DIR/fullchain.pem" | cut -d= -f2)
    EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
    CURRENT_EPOCH=$(date +%s)
    DAYS_UNTIL_EXPIRY=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))
    
    echo "$(date): Certificate expires in $DAYS_UNTIL_EXPIRY days" | tee -a "$LOG_FILE"
    
    if [ $DAYS_UNTIL_EXPIRY -lt 30 ]; then
        echo "$(date): Certificate expires soon, renewing..." | tee -a "$LOG_FILE"
        
        # Renew certificate in the domain directory
        docker exec acme-companion /app/acme.sh --renew \
          --domain webhook.xbonell.com \
          --webroot /usr/share/nginx/html \
          --email ${LETSENCRYPT_EMAIL} \
          --server letsencrypt \
          --keylength 4096 \
          --fullchain-file /etc/nginx/certs/_test_webhook.xbonell.com/fullchain.pem \
          --key-file /etc/nginx/certs/_test_webhook.xbonell.com/key.pem \
          --ca-file /etc/nginx/certs/_test_webhook.xbonell.com/chain.pem
        
        # Create symbolic links
        create_symlinks
        
        # Reload nginx
        docker exec nginx-proxy nginx -s reload
        
        echo "$(date): Certificate renewed successfully" | tee -a "$LOG_FILE"
    else
        echo "$(date): Certificate is still valid, ensuring symbolic links exist..." | tee -a "$LOG_FILE"
        create_symlinks
    fi
else
    echo "$(date): Certificate not found, generating new certificate..." | tee -a "$LOG_FILE"
    
    # Generate new certificate in the domain directory
    docker exec acme-companion /app/acme.sh --issue \
      --domain webhook.xbonell.com \
      --webroot /usr/share/nginx/html \
      --email ${LETSENCRYPT_EMAIL} \
      --server letsencrypt \
      --keylength 4096 \
      --fullchain-file /etc/nginx/certs/_test_webhook.xbonell.com/fullchain.pem \
      --key-file /etc/nginx/certs/_test_webhook.xbonell.com/key.pem \
      --ca-file /etc/nginx/certs/_test_webhook.xbonell.com/chain.pem
    
    # Create symbolic links
    create_symlinks
    
    # Reload nginx
    docker exec nginx-proxy nginx -s reload
    
    echo "$(date): Certificate generated successfully" | tee -a "$LOG_FILE"
fi

echo "$(date): Certificate renewal check completed" | tee -a "$LOG_FILE" 