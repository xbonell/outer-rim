# AI Agent Reference Documentation

This document provides comprehensive context for AI agents working on this project.

## Project Overview

**Outer Rim** is a Docker Compose-based reverse proxy solution for hosting multiple web applications behind a single domain, with automatic SSL certificate management via Let's Encrypt.

### Key Features
- Reverse proxy with nginx-proxy
- Automatic SSL (Let's Encrypt)
- Easy Docker integration
- Security-focused setup and monitoring
- Hybrid architecture supporting both Docker containers and native services

### Vision & Context
- Designed for developers/ops hosting multiple web apps securely and easily
- User needs: simple setup, automatic HTTPS, minimal manual intervention, strong security defaults
- Context: Used on servers with Docker, a domain, and open ports 80/443

## Technical Stack

### Core Technologies
- **Docker** & **Docker Compose** - Container orchestration
- **nginx-proxy** (nginxproxy/nginx-proxy:1.8) - Reverse proxy that automatically routes traffic based on `VIRTUAL_HOST` environment variables
- **acme-companion** (nginxproxy/acme-companion:latest) - Automatically generates and renews Let's Encrypt SSL certificates
- **Nginx** - For proxied apps and custom configurations
- **Environment variables** - For configuration management

### Security Features
- Read-only filesystems where possible
- No-new-privileges security option
- Resource limits to prevent DoS attacks
- Health checks for all services
- Latest image tags for security patches
- Isolated Docker network with custom subnet
- Rate limiting to prevent abuse
- Security headers (HSTS, CSP, X-Frame-Options, etc.)
- SSL/TLS 1.2+ only with secure cipher suites
- Proper file permissions (600 for sensitive files)
- Hidden file protection in nginx
- Sensitive file blocking (.env, .log, .sql, etc.)
- Docker socket read-only access

## Architecture Patterns

### System Patterns & Practices
- **Reverse proxy pattern** - Centralized routing through nginx-proxy
- **Automated certificate management** - Let's Encrypt via acme-companion
- **Docker network isolation** - Custom bridge network (172.20.0.0/16)
- **Security as code** - Checklists, scripts, health checks
- **Monitoring and logging** - Comprehensive logging for audit trails

### Architecture Overview
- **Docker-Focused Setup**: Docker containers for main services
- **Custom Routing**: nginx-proxy with custom configuration files
- **SSL Management**: Automatic for Docker services via acme-companion
- **Deployment**: GitHub Actions for automated deployment
- **Maintenance**: Reduced complexity with webhook infrastructure removed

### Network Configuration
All services that need to be proxied should be connected to the `web` network:
- Custom bridge network: `nginx-proxy`
- Subnet: `172.20.0.0/16`
- External: false

## Style Guide & Conventions

### Code Conventions
- Use environment variables for secrets/config
- Restrict file permissions (600 for sensitive files)
- Use latest image tags for security
- YAML for Docker Compose
- Markdown for documentation and checklists

### File Structure
```
outer-rim/
├── docker-compose.yml    # Main Docker Compose configuration
├── .env                  # Environment variables (create from env.example)
├── .gitignore           # Git ignore rules
├── setup.sh             # Secure setup script
├── security-checklist.md # Security audit checklist
├── nginx/
│   ├── certs/           # SSL certificates (auto-generated)
│   ├── vhost.d/         # Custom nginx configurations
│   ├── conf.d/          # Additional nginx configurations
│   └── html/            # Static files
├── sites/               # Static site content
└── README.md            # Main project documentation
```

## Current Status

### Setup Status
- ✅ Core infrastructure is configured
- ✅ Webhook system removed (July 28, 2025)
- ✅ Comprehensive security checklist and setup script available
- ✅ Docker Compose with nginx-proxy and acme-companion ready
- ✅ Simplified setup with GitHub Actions deployment

### Working Components
- ✅ nginx-proxy with custom configuration support
- ✅ acme-companion for SSL certificate generation
- ✅ Docker Compose configuration (webhook services removed)
- ✅ Custom nginx configuration for non-Docker services
- ✅ Manual SSL certificate generation process
- ✅ Simplified architecture with GitHub Actions deployment

### Current Issues
- ⚠️ Missing site content (sites/xbonell.com/dist directory empty)
- ⚠️ Environment file needs proper configuration (LETSENCRYPT_EMAIL)

### Next Steps
1. Configure .env file with valid email
2. Deploy site content to sites/xbonell.com/dist
3. Run setup.sh and deploy services
4. Validate SSL certificate generation for xbonell.com
5. Test complete system functionality

## Recent Work

### Nginx Configuration SEO Improvements
**Status**: ✅ COMPLETED

**Objective**: Improve SEO by using permanent redirects and canonical domain setup

**Implementation**:
- Changed language-based redirects from 302 (temporary) to 301 (permanent) for better SEO
- Simplified www subdomain configurations to redirect-only (canonical domain setup)
- Added SEO-focused comments explaining redirect strategy
- Applied to: bgespecialitats.com, www.bgespecialitats.com, xbonell.com, www.xbonell.com

**Result**: Better SEO performance with permanent redirects and consolidated domain authority

**Technical Details**:
- Non-www domains: Use 301 redirects for language-based routing
- WWW domains: Simplified to redirect-only configurations (www → non-www)
- Prevents duplicate content issues and consolidates SEO value

### Webhook Infrastructure Removal (July 28, 2025)
**Status**: ✅ ARCHIVED

**Objective**: Remove webhook infrastructure due to GitHub Actions migration

**Implementation**:
- Removed 7 webhook-related files (scripts, configs, service files)
- Updated README.md to remove webhook references
- Verified no impact on existing Docker services
- Confirmed no webhook artifacts in system

**Result**: Clean architecture with simplified maintenance

**Manual Actions Required**:
1. Remove webhook.xbonell.com DNS records from DNS provider
2. Restart nginx-proxy container: `docker-compose restart nginx-proxy`

## Configuration

### Environment Variables
The `.env` file contains:
- `LETSENCRYPT_EMAIL`: Your email address for Let's Encrypt notifications (REQUIRED - must be changed from default)
- `ACME_CA_URI`: ACME server URI (staging for testing, production for live)
- `MAX_CERTS_PER_DOMAIN`: Maximum certificates per domain (default: 5)
- `CERT_RENEWAL_THRESHOLD`: Days before expiration to renew (default: 30)
- `RATE_LIMIT_REQUESTS`: Rate limiting requests per window (default: 100)
- `RATE_LIMIT_WINDOW`: Rate limiting time window (default: 1m)
- `LOG_LEVEL`: Logging level (default: info)

### Adding Applications

#### Docker Containers
To add web applications, create additional services in `docker-compose.yml`:
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
1. Create custom nginx configuration in `nginx/conf.d/your-domain.com.conf`
2. Generate SSL certificate manually or set up automation
3. Configure routing to your native service

## SSL Certificate Management

### Automatic Renewal
- **Automatic Generation**: Certificates are created when domains are first accessed
- **Automatic Renewal**: Certificates are renewed before expiration
- **Storage**: Certificates are stored in `./nginx/certs/`

### Manual Certificate Generation
For troubleshooting:
```bash
# Check certificate status
docker-compose logs acme-companion

# Verify certificates are generated
ls -la nginx/certs/

# Test certificate renewal
docker-compose restart acme-companion
```

## Services

### nginx-proxy
- **Image**: `nginxproxy/nginx-proxy:1.8`
- **Ports**: 80, 443
- **Purpose**: Reverse proxy that automatically routes traffic based on `VIRTUAL_HOST` environment variables
- **Security**: Read-only filesystem, resource limits, no new privileges

### acme-companion
- **Image**: `nginxproxy/acme-companion:latest`
- **Purpose**: Automatically generates and renews Let's Encrypt SSL certificates
- **Dependencies**: nginx-proxy
- **Security**: Resource limits, no new privileges

### xbonell.com (Example Site)
- **Image**: `nginx:alpine`
- **Purpose**: Example static site configuration
- **Domains**: xbonell.com, www.xbonell.com
- **Security**: Read-only filesystem, resource limits

## Troubleshooting

### Certificate Issues
- Ensure your domain points to the server's IP address
- Check that ports 80 and 443 are open
- Verify the email address in your `.env` file
- **HTTPS not working but HTTP works**: Check if `ACME_CA_URI` is set to staging. Staging certificates (with `_test_` prefix) are not trusted by browsers. Set `ACME_CA_URI=https://acme-v02.api.letsencrypt.org/directory` in your `.env` file and recreate the acme-companion container
- **Certificate generation failures**: Check DNS resolution with `dig +short your-domain.com A`. Ensure DNS is properly configured before certificate generation

### Container Communication
- Make sure all containers are on the `web` network
- Check that `VIRTUAL_HOST` environment variables are set correctly

### Logs
```bash
# nginx-proxy logs
docker-compose logs nginx-proxy

# acme-companion logs
docker-compose logs acme-companion

# All services logs
docker-compose logs -f

# Check service status
docker-compose ps
```

## Security Considerations

- Keep your `.env` file secure and never commit it to version control
- Regularly update Docker images for security patches
- Monitor certificate renewal logs
- Use the provided security checklist for regular audits
- Consider using Docker secrets for sensitive environment variables in production
- Run security scans regularly with tools like Trivy

## Maintenance

### Regular Security Audits
Use the provided security checklist:
```bash
cat security-checklist.md
```

### Updates
```bash
# Update Docker images
docker-compose pull

# Restart services with new images
docker-compose up -d

# Check for updates
docker-compose images
```

### Monitoring
```bash
# Check service health
docker-compose ps

# Monitor logs
docker-compose logs -f

# Check resource usage
docker stats
```

