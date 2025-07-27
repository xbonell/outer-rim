#!/bin/bash

# Check webhook certificate status and send alerts if needed

CERT_FILE="nginx/certs/webhook.xbonell.com.crt"
ALERT_DAYS=7

if [ -f "$CERT_FILE" ]; then
    EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
    EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
    CURRENT_EPOCH=$(date +%s)
    DAYS_UNTIL_EXPIRY=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))
    
    if [ $DAYS_UNTIL_EXPIRY -lt $ALERT_DAYS ]; then
        echo "WARNING: webhook.xbonell.com certificate expires in $DAYS_UNTIL_EXPIRY days"
        # Add your alert mechanism here (email, Slack, etc.)
    fi
else
    echo "ERROR: webhook.xbonell.com certificate not found"
    # Add your alert mechanism here
fi 