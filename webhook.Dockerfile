FROM node:22-alpine

# Install required packages
RUN apk add --no-cache curl bash git openssh

# Create webhook user
RUN adduser -D -u 1000 webhookuser

# Download and install webhook
RUN mkdir -p /usr/local/bin && \
    curl -L https://github.com/adnanh/webhook/releases/download/2.8.1/webhook-linux-amd64.tar.gz | tar xz && \
    mv webhook-linux-amd64/webhook /usr/local/bin/webhook && \
    chmod +x /usr/local/bin/webhook && \
    rm -rf webhook-linux-amd64

# Create necessary directories
RUN mkdir -p /etc/webhook/scripts /etc/webhook/sites

# Switch to webhook user
USER webhookuser

# Expose port
EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:9000/ || exit 1

# Start webhook
CMD ["/usr/local/bin/webhook", "-hooks", "/etc/webhook/hooks.json", "-verbose", "-port", "9000"] 