#!/bin/bash

# Webhook Service Startup Script
# This script starts the webhook service natively on the host

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_FILE="$SCRIPT_DIR/hooks/hooks.json"

echo "🚀 Starting webhook service..."

# Check if webhook binary exists
if ! command -v webhook &> /dev/null; then
    echo "❌ Webhook binary not found. Installing..."
    curl -L https://github.com/adnanh/webhook/releases/download/2.8.1/webhook-linux-amd64.tar.gz | tar xz
    sudo mv webhook-linux-amd64/webhook /usr/local/bin/webhook
    sudo chmod +x /usr/local/bin/webhook
    rm -rf webhook-linux-amd64
    echo "✅ Webhook installed successfully"
fi

# Check if hooks file exists
if [ ! -f "$HOOKS_FILE" ]; then
    echo "❌ Hooks file not found: $HOOKS_FILE"
    exit 1
fi

echo "📋 Using hooks file: $HOOKS_FILE"
echo "🌐 Webhook will be available at: http://localhost:9000"
echo "🔗 Access via: https://webhook.xbonell.com"
echo ""
echo "Press Ctrl+C to stop the service"

# Start webhook service
exec webhook -hooks "$HOOKS_FILE" -verbose -port 9000 