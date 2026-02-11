# Use official Caddy image (includes all standard modules)
FROM caddy:2.7-alpine

# Copy Caddyfile configuration
COPY Caddyfile /etc/caddy/Caddyfile

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Run as root for Render compatibility
# Render will map this to UID 1000 internally
USER root

# Start Caddy with our configuration
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
