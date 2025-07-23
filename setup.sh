#!/bin/bash

# Outer Rim Secure Setup Script
# This script helps set up the secure configuration

set -e

echo "🔒 Outer Rim Secure Setup"
echo "=========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

print_status "Creating necessary directories..."

# Create directories with proper permissions
mkdir -p nginx/certs nginx/vhost.d nginx/html nginx/conf.d acme logs

# Set proper permissions
chmod 755 nginx/
chmod 600 nginx/certs/
chmod 644 nginx/conf.d/
chmod 755 logs/

print_status "Setting up environment file..."

# Check if .env file exists
if [ ! -f .env ]; then
    if [ -f env.example ]; then
        cp env.example .env
        print_warning "Created .env file from env.example. Please edit it with your actual values."
    else
        print_error "env.example file not found. Please create a .env file manually."
        exit 1
    fi
else
    print_status ".env file already exists."
fi

# Set proper permissions for .env file
chmod 600 .env

# Validate that LETSENCRYPT_EMAIL is set
if ! grep -q "^LETSENCRYPT_EMAIL=" .env || grep -q "^LETSENCRYPT_EMAIL=your-email@example.com" .env; then
    print_error "LETSENCRYPT_EMAIL is not properly configured in .env file."
    print_error "Please edit .env and set a valid email address for Let's Encrypt notifications."
    exit 1
fi

print_status "Environment file validation passed."

print_status "Checking Docker images..."

# Pull latest images
print_status "Pulling latest Docker images..."
docker-compose pull

print_status "Validating configuration..."

# Validate docker-compose configuration
docker-compose config > /dev/null
if [ $? -eq 0 ]; then
    print_status "Docker Compose configuration is valid."
else
    print_error "Docker Compose configuration is invalid. Please check your docker-compose.yml file."
    exit 1
fi

print_status "Setting up firewall rules (requires sudo)..."

# Setup basic firewall rules
if command -v ufw &> /dev/null; then
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 22/tcp  # SSH
    print_status "Firewall rules configured."
else
    print_warning "ufw not found. Please configure your firewall manually."
fi

print_status "Creating security monitoring script..."

# Create a simple monitoring script
cat > monitor.sh << 'EOF'
#!/bin/bash

echo "🔍 Outer Rim Security Monitor"
echo "============================="

# Check container status
echo "Container Status:"
docker-compose ps

echo -e "\nResource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo -e "\nRecent Logs (last 10 lines):"
docker-compose logs --tail=10

echo -e "\nCertificate Status:"
docker exec acme-companion acme.sh --list 2>/dev/null || echo "acme-companion not running"

echo -e "\nSecurity Check Complete"
EOF

chmod +x monitor.sh

print_status "Setup complete! 🎉"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your actual email address"
echo "2. Run: docker-compose up -d"
echo "3. Monitor with: ./monitor.sh"
echo "4. Check security checklist: cat security-checklist.md"
echo ""
echo "For development/testing, copy docker-compose.override.yml.example to docker-compose.override.yml"
echo ""
print_warning "Remember to:"
echo "- Keep your .env file secure"
echo "- Regularly update Docker images"
echo "- Monitor logs for suspicious activity"
echo "- Follow the security checklist" 