# Outer Rim

A Docker Compose setup for nginx-proxy with automatic SSL certificate management using Let's Encrypt.

## Overview

This project provides a reverse proxy solution using nginx-proxy with automatic SSL certificate generation and renewal through Let's Encrypt. It's perfect for hosting multiple web applications behind a single domain with automatic HTTPS.

## Features

- **Reverse Proxy**: Routes traffic to multiple containers based on hostnames
- **Automatic SSL**: Let's Encrypt certificates are automatically generated and renewed
- **Docker Integration**: Seamlessly works with Docker containers
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

2. **Create environment file**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and add your email for Let's Encrypt notifications:
   ```
   DEFAULT_EMAIL=your-email@example.com
   ```

3. **Create required directories**
   ```bash
   mkdir -p nginx/certs nginx/vhost.d nginx/html
   ```

4. **Start the services**
   ```bash
   docker-compose up -d
   ```

## Configuration

### Environment Variables

Create a `.env` file with the following variables:

- `DEFAULT_EMAIL`: Your email address for Let's Encrypt notifications

### Adding Your Applications

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

### Network Configuration

All services that need to be proxied should be connected to the `web` network:

```yaml
networks:
  web:
    external: true
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

## Security Considerations

- Keep your `.env` file secure and never commit it to version control
- Regularly update Docker images for security patches
- Monitor certificate renewal logs
- Consider using Docker secrets for sensitive environment variables

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