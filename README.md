# PageQuik Caddy SSL Proxy

This directory contains the Caddy reverse proxy configuration that handles SSL termination for custom domains.

## Overview

**Purpose:** Automatically provision SSL certificates for user custom domains via Let's Encrypt

**How it works:**
1. User points their domain (A record) to this Caddy proxy IP
2. Request arrives at Caddy with custom domain as Host header
3. Caddy asks PageQuik API if domain is allowed: `/api/caddy/check-domain?domain=example.com`
4. If allowed (200 response), Caddy automatically provisions SSL via Let's Encrypt
5. Caddy proxies request to main PageQuik app with original Host header
6. Main app middleware routes to `/_domain/[domain]` handler
7. Site content served with SSL

## Files

- `Caddyfile` - Caddy configuration with on-demand TLS
- `Dockerfile` - Container image for Caddy proxy
- `README.md` - This file

## Environment Variables

Set these in Render dashboard for the Caddy proxy service:

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `APP_URL` | No | `https://app.pagequik.com` | Main PageQuik app URL to proxy to |
| `LETSENCRYPT_EMAIL` | No | `noreply@pagequik.com` | Email for Let's Encrypt notifications |

## Deployment to Render

### Step 1: Create New Web Service

1. Go to Render Dashboard: https://dashboard.render.com
2. Click "New +" → "Web Service"
3. Connect to GitHub repo: `malibu-tech/pagequik`
4. Configure service:
   - **Name:** `pagequik-caddy-proxy`
   - **Region:** Same as main app (for low latency)
   - **Branch:** `main`
   - **Root Directory:** `caddy-proxy`
   - **Runtime:** `Docker`
   - **Instance Type:** `Starter` ($7/mo) or `Standard` ($25/mo)

### Step 2: Set Environment Variables

In Render service settings, add:
```
APP_URL=https://app.pagequik.com
LETSENCRYPT_EMAIL=noreply@pagequik.com
```

### Step 3: Deploy

1. Click "Create Web Service"
2. Wait for deployment to complete
3. Note the service URL: `pagequik-caddy-proxy.onrender.com`

### Step 4: Get Static IP (Important!)

Render doesn't provide static IPs by default. You have two options:

**Option A: Use CNAME (Recommended - Easier for users)**
1. Create DNS record: `proxy.pagequik.com` CNAME → `pagequik-caddy-proxy.onrender.com`
2. Tell users to CNAME their domains to: `proxy.pagequik.com`
3. Update UI to show CNAME instructions

**Option B: Use A Record with Render IP**
1. Check Render service IP: `dig pagequik-caddy-proxy.onrender.com`
2. Note: Render IPs are stable but not guaranteed permanent
3. Tell users to point A record to this IP
4. Update UI to show A record instructions

**Recommendation:** Use Option A (CNAME to proxy.pagequik.com) - more reliable and easier to manage.

## Testing

### Test 1: Verify Caddy is Running

```bash
curl -I https://pagequik-caddy-proxy.onrender.com
```

Expected: 200 OK (or redirect)

### Test 2: Test with Custom Domain

1. Add test domain in PageQuik admin
2. Point domain to proxy via CNAME: `proxy.pagequik.com`
3. Wait 2-5 minutes for DNS propagation
4. Visit domain in browser
5. Verify SSL certificate is valid (Let's Encrypt)
6. Verify site loads correctly

### Test 3: Check Caddy Logs

```bash
render logs -s pagequik-caddy-proxy -o text --tail
```

Look for:
- "obtaining certificate" - Caddy requesting SSL cert
- "certificate obtained successfully" - SSL provisioned
- "asking ask endpoint" - Caddy checking with API

## Troubleshooting

### Domain Shows "Service Unavailable"
- Check Caddy logs for errors
- Verify APP_URL is correct
- Verify main app is running

### SSL Certificate Not Provisioning
- Verify domain is pointing to proxy (dig/nslookup)
- Check API endpoint returns 200 for domain
- Verify Let's Encrypt rate limits not exceeded
- Check Caddy logs for "ask endpoint denied"

### Domain Not Found
- Verify domain is in database with domain_verified_at set
- Check API endpoint `/api/caddy/check-domain?domain=example.com`
- Ensure user is premium

## Architecture

```
┌─────────────────┐
│  User's Domain  │ (www.example.com)
│  DNS: CNAME →   │
│  proxy.pagequik │
└────────┬────────┘
         │
         ↓
┌─────────────────────────────────┐
│   Caddy SSL Proxy (Render)      │
│   - On-demand TLS               │
│   - Auto SSL via Let's Encrypt  │
│   - Checks /api/caddy/check     │
└────────┬────────────────────────┘
         │
         ↓ (proxy with Host header)
┌─────────────────────────────────┐
│   Main PageQuik App (Render)    │
│   - Receives Host: example.com  │
│   - Middleware → /_domain/...   │
│   - Serves site from R2         │
└─────────────────────────────────┘
```

## Security Considerations

1. **Domain Verification:** Caddy only issues certificates for domains approved by our API
2. **Rate Limiting:** On-demand TLS has built-in rate limiting (1 check/minute/domain)
3. **Let's Encrypt Limits:** 50 certificates per domain per week (should be fine)
4. **API Security:** `/api/caddy/check-domain` should be public but rate-limited

## Cost Analysis

**Caddy Proxy Instance:**
- Starter: $7/month (512 MB RAM, 0.5 CPU)
- Standard: $25/month (2 GB RAM, 1 CPU)

**Recommendation:** Start with Starter, upgrade if needed.

**Let's Encrypt:** Free (no cost per certificate)

## Monitoring

Key metrics to monitor:
1. Certificate provisioning success rate
2. Proxy response times
3. SSL certificate renewal status
4. Let's Encrypt rate limit usage

## Support

- Caddy Docs: https://caddyserver.com/docs/
- On-Demand TLS: https://caddyserver.com/docs/caddyfile/options#on-demand-tls
- Let's Encrypt: https://letsencrypt.org/docs/
