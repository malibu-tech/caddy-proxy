# Use official Caddy image (includes all standard modules)
FROM caddy:2.7-alpine

# Copy Caddyfile configuration
COPY Caddyfile /etc/caddy/Caddyfile

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Run as root for Render compatibility
USER root

# Ensure caddy binary is executable
RUN chmod +x /usr/bin/caddy

# Start Caddy with our configuration (shell form for Render compatibility)
CMD caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
