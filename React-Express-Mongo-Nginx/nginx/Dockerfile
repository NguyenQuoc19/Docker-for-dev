# Stage 1: Nginx setup
FROM nginx:1.28.0-alpine-slim

# Install OpenSSL to generate self-signed certificates
RUN apk add --no-cache openssl

# Create directory for SSL certificates
RUN mkdir -p /etc/ssl/self-signed

# Generate self-signed certificate for local.site
# Create private key and certificate in one command
# Use -nodes to skip passphrase for automation
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/self-signed/key.pem \
    -out /etc/ssl/self-signed/cert.pem \
    -subj "/C=VN/ST=Ha Noi/L=Ha Noi/O=Your Organization/OU=Dev Team/CN=*.local.site" \
    -addext "subjectAltName=DNS:local.site,DNS:*.local.site,DNS:admin.local.site,DNS:api.local.site"

# Delete the default welcome to nginx page.
RUN rm /usr/share/nginx/html/*

# Copy over the custom default configs.
COPY configs/default.conf /etc/nginx/conf.d/default.conf

# Expose ports for HTTP and HTTPS
EXPOSE $NGINX_PORT $NGINX_SSL_PORT

# Start nginx in the foreground to play nicely with Docker.
CMD ["nginx", "-g", "daemon off;"]
