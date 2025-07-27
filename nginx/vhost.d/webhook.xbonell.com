# Proxy configuration for webhook.xbonell.com
# This routes traffic to the natively running webhook service on port 9000

proxy_pass http://172.17.0.1:9000;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;

# Webhook specific headers
proxy_set_header Connection "";
proxy_http_version 1.1;

# Timeouts
proxy_connect_timeout 60s;
proxy_send_timeout 60s;
proxy_read_timeout 60s; 