# Use official Caddy image (includes all standard modules)
FROM caddy:2.7-alpine

# Copy Caddyfile configuration
COPY Caddyfile /etc/caddy/Caddyfile

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# The official Caddy image already:
# - Creates /data/caddy directory
# - Runs as non-root caddy user
# - Has proper permissions set
# - Includes health checks

# Start Caddy with our configuration
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
