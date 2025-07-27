# Outer Rim

A Docker Compose setup for nginx-proxy with automatic SSL certificate management using Let's Encrypt, featuring a hybrid architecture that supports both Docker containers and native services.

## Overview

This project provides a reverse proxy solution using nginx-proxy with automatic SSL certificate generation and renewal through Let's Encrypt. It's perfect for hosting multiple web applications behind a single domain with automatic HTTPS, including support for native services running outside of Docker containers.

## Features

- **Reverse Proxy**: Routes traffic to multiple containers based on hostnames
- **Automatic SSL**: Let's Encrypt certificates are automatically generated and renewed
- **Hybrid Architecture**: Supports both Docker containers and native services
- **Docker Integration**: Seamlessly works with Docker containers
- **Native Service Support**: Custom nginx configuration for non-Docker services
- **Automated Certificate Renewal**: Cron-based SSL certificate management
- **Easy Setup**: Simple configuration with Docker Compose

## Prerequisites

- Docker
- Docker Compose
- A domain name pointing to your server
- Ports 80 and 443 available on your host

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd outer-rim
   ```

2. **Run the secure setup script**
   ```bash
   ./setup.sh
   ```
   
   This script will:
   - Create necessary directories with proper permissions
   - Set up environment file from template
   - Validate Docker Compose configuration
   - Configure basic firewall rules
   - Create monitoring scripts

3. **Edit environment file**
   ```bash
   nano .env
   ```
   
   **IMPORTANT**: Update with your actual email for Let's Encrypt notifications:
   ```
   LETSENCRYPT_EMAIL=your-actual-email@example.com
   ```
   
   ⚠️ **Security Note**: Never use the default email address. The setup script will validate that you've changed it.

4. **Start the services**
   ```bash
   docker-compose up -d
   ```

5. **Set up SSL certificate automation**
   ```bash
   # Make renewal script executable
   chmod +x scripts/renew-webhook-cert.sh
   
   # Add to crontab (runs daily at 2 AM)
   crontab -e
   # Add this line:
   0 2 * * * /path/to/outer-rim/scripts/renew-webhook-cert.sh
   ```

6. **Monitor security**
   ```bash
   ./monitor.sh
   ```

## Configuration

### Environment Variables

Create a `.env` file with the following variables:

- `LETSENCRYPT_EMAIL`: Your email address for Let's Encrypt notifications

### Adding Your Applications

#### Docker Containers

To add your web applications, create additional services in your `docker-compose.yml`:

```yaml
services:
  your-app:
    image: your-app-image
    environment:
      - VIRTUAL_HOST=your-domain.com
      - LETSENCRYPT_HOST=your-domain.com
      - LETSENCRYPT_EMAIL=your-email@example.com
    networks:
      - web
```

#### Native Services

For native services running outside Docker containers:

1. **Create custom nginx configuration** in `nginx/conf.d/your-domain.com.conf`
2. **Generate SSL certificate manually** or set up automation
3. **Configure routing** to your native service

Example for a native webhook service:
```bash
# Generate SSL certificate
./scripts/generate-webhook-cert.sh

# Set up automatic renewal
chmod +x scripts/renew-webhook-cert.sh
crontab -e
# Add: 0 2 * * * /path/to/outer-rim/scripts/renew-webhook-cert.sh
```

### Network Configuration

All services that need to be proxied should be connected to the `web` network:

```yaml
networks:
  web:
    external: false
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: nginx-proxy
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

## SSL Certificate Management

### Automatic Renewal

The system includes automated SSL certificate renewal for native services:

- **Renewal Script**: `scripts/renew-webhook-cert.sh`
- **Monitoring Script**: `scripts/check-webhook-cert.sh`
- **Logging**: `logs/webhook-cert-renewal.log`
- **Schedule**: Daily cron job (recommended: 2 AM)

### Manual Certificate Generation

For initial setup or troubleshooting:

```bash
# Generate certificate for webhook service
./scripts/generate-webhook-cert.sh

# Check certificate status
./scripts/check-webhook-cert.sh
```

## Directory Structure

```
outer-rim/
├── docker-compose.yml    # Main Docker Compose configuration
├── .env                  # Environment variables (create from .env.example)
├── .gitignore           # Git ignore rules
├── nginx/
│   ├── certs/           # SSL certificates (auto-generated)
│   ├── vhost.d/         # Custom nginx configurations
│   └── html/            # Static files
└── README.md            # This file
```

## Services

### nginx-proxy
- **Image**: `nginxproxy/nginx-proxy`
- **Ports**: 80, 443
- **Purpose**: Reverse proxy that automatically routes traffic based on `VIRTUAL_HOST` environment variables

### acme-companion
- **Image**: `nginxproxy/acme-companion`
- **Purpose**: Automatically generates and renews Let's Encrypt SSL certificates
- **Dependencies**: nginx-proxy

## Usage Examples

### Example 1: Simple Web Application
```yaml
services:
  my-webapp:
    image: nginx:alpine
    environment:
      - VIRTUAL_HOST=myapp.example.com
      - LETSENCRYPT_HOST=myapp.example.com
      - LETSENCRYPT_EMAIL=admin@example.com
    networks:
      - web
```

### Example 2: Multiple Applications
```yaml
services:
  frontend:
    image: my-frontend:latest
    environment:
      - VIRTUAL_HOST=app.example.com
      - LETSENCRYPT_HOST=app.example.com
      - LETSENCRYPT_EMAIL=admin@example.com
    networks:
      - web

  api:
    image: my-api:latest
    environment:
      - VIRTUAL_HOST=api.example.com
      - LETSENCRYPT_HOST=api.example.com
      - LETSENCRYPT_EMAIL=admin@example.com
    networks:
      - web
```

## SSL Certificates

SSL certificates are automatically:
- Generated when a new domain is accessed
- Renewed before expiration
- Stored in `./nginx/certs/`

## Troubleshooting

### Certificate Issues
- Ensure your domain points to the server's IP address
- Check that ports 80 and 443 are open
- Verify the email address in your `.env` file

### Container Communication
- Make sure all containers are on the `web` network
- Check that `VIRTUAL_HOST` environment variables are set correctly

### Logs
View logs for troubleshooting:
```bash
# nginx-proxy logs
docker-compose logs nginx-proxy

# acme-companion logs
docker-compose logs acme-companion
```

## Security Features

This setup includes comprehensive security measures:

### Container Security
- **Read-only root filesystems** where possible
- **No new privileges** security option
- **Resource limits** to prevent DoS attacks
- **Health checks** for all services
- **Latest image tags** for security patches

### Network Security
- **Isolated Docker network** with custom subnet
- **Rate limiting** to prevent abuse
- **Security headers** (HSTS, CSP, X-Frame-Options, etc.)
- **SSL/TLS 1.2+ only** with secure cipher suites

### Access Control
- **Proper file permissions** (600 for sensitive files)
- **Hidden file protection** in nginx
- **Sensitive file blocking** (.env, .log, .sql, etc.)
- **Docker socket read-only access**

### Monitoring & Maintenance
- **Security checklist** for regular audits
- **Automated setup script** with security validation
- **Monitoring script** for ongoing security checks
- **Comprehensive logging** for audit trails

## Security Considerations

- Keep your `.env` file secure and never commit it to version control
- Regularly update Docker images for security patches
- Monitor certificate renewal logs
- Use the provided security checklist for regular audits
- Consider using Docker secrets for sensitive environment variables in production
- Run security scans regularly with tools like Trivy

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) - The reverse proxy solution
- [acme-companion](https://github.com/nginx-proxy/acme-companion) - Let's Encrypt companion
- [Let's Encrypt](https://letsencrypt.org/) - Free SSL certificates 