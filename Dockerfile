# Use official Caddy image (includes all standard modules)
FROM caddy:2.7-alpine

# Copy Caddyfile configuration
COPY Caddyfile /etc/caddy/Caddyfile

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Run as root for Render compatibility
USER root

# Use ENTRYPOINT instead of CMD for better Render compatibility
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
