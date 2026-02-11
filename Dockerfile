# Use official Caddy image with builder
FROM caddy:2.7-builder AS builder

# Build Caddy with required modules
RUN xcaddy build \
    --with github.com/caddyserver/replace-response

# Final lightweight image
FROM caddy:2.7-alpine

# Copy the built Caddy binary
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Copy Caddyfile
COPY Caddyfile /etc/caddy/Caddyfile

# Create directory for Caddy data (certificates, etc.)
RUN mkdir -p /data/caddy && \
    chown -R caddy:caddy /data/caddy

# Expose ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

# Run as non-root user
USER caddy

# Start Caddy
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
