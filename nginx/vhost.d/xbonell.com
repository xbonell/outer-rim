# Redirect based on language if requesting root
location = / {
    if ($http_accept_language ~* ^ca) {
        return 302 /ca/;
    }
    if ($http_accept_language ~* ^es) {
        return 302 /es/;
    }
    if ($http_accept_language ~* ^en) {
        return 302 /en/;
    }
    return 302 /es/;
}

# Serve language-specific static files
location ~ ^/(ca|es|en)/ {
    root /usr/share/nginx/html;
    try_files $uri $uri/ /error.html =404;
}

# Serve static files and fallback to error
location / {
    root /usr/share/nginx/html;
    try_files $uri $uri/ /error/ =404;
}

# Error page handling
error_page 400 401 403 404 500 502 503 504 /error/;

location = /error/ {
    root /usr/share/nginx/html;
    index index.html;
    # No try_files needed if index.html exists in /usr/share/nginx/html/error/
    internal;
}

# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' data: https://fonts.gstatic.com; connect-src 'self'; frame-ancestors 'self';" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# Remove server signature
server_tokens off;

# Security settings
client_max_body_size 10M;
client_body_timeout 12;
client_header_timeout 12;
