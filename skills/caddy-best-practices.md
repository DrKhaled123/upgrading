# Caddy Best Practices — Production Reference
## Caddy alone: configuration, TLS, security, performance, operations

---

## Why Caddy Over Nginx/Apache

| Feature | Caddy | Nginx | Apache |
|---|---|---|---|
| Automatic HTTPS | ✅ built-in | ❌ manual certbot | ❌ manual certbot |
| Certificate renewal | ✅ automatic | ❌ cron job | ❌ cron job |
| HTTP/3 (QUIC) | ✅ built-in | ⚠ nginx-quic build | ❌ |
| Config syntax | Simple | Verbose | Very verbose |
| Config reload | ✅ zero-downtime | ✅ | ✅ |
| OCSP stapling | ✅ automatic | Manual | Manual |
| Default config | Secure | Requires hardening | Requires hardening |

Caddy's killer feature: point it at a domain, it handles ACME challenge,
certificate issuance, renewal, and OCSP stapling — zero cron jobs, zero certbot.

---

## 1. Installation

### Method A: Docker (recommended for containerized stacks)

```yaml
# docker-compose.yml
services:
  caddy:
    image: caddy:2.8.4-alpine      # pin exact version
    container_name: caddy_proxy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"              # HTTP/3 requires UDP
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data           # TLS certificates — MUST be a named volume
      - caddy_config:/config
    environment:
      - DOMAIN=${DOMAIN}
      - APP_BACKEND=app:3000

volumes:
  caddy_data:     # losing this = re-requesting certs = hitting rate limits
  caddy_config:
```

### Method B: System install (direct on VPS)

```bash
# Official install script
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | \
  sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | \
  sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update && sudo apt install caddy

# Caddy runs as a systemd service — starts on boot automatically
sudo systemctl enable --now caddy

# Caddyfile location
/etc/caddy/Caddyfile

# Certificates stored in
/var/lib/caddy/.local/share/caddy/
```

---

## 2. Caddyfile Structure

### Global options block

```caddyfile
{
    # Required for Let's Encrypt expiry warning emails
    email admin@yourdomain.com

    # Protocols — enable all for best performance
    servers {
        protocols h1 h2 h2c h3
    }

    # Reduce log noise in production
    log {
        level WARN
    }

    # Optional: use ZeroSSL instead of Let's Encrypt
    # Useful if you hit Let's Encrypt rate limits
    # cert_issuer zerossl {
    #     api_key {$ZEROSSL_API_KEY}
    # }

    # Optional: ACME CA for internal/staging (never real certs)
    # acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
}
```

> **The global block must come first** in your Caddyfile. Only one global
> block is allowed. Everything inside `{ }` before any site blocks is global.

### Site block patterns

```caddyfile
# Single domain
yourdomain.com { ... }

# Domain + www (handle both)
yourdomain.com, www.yourdomain.com { ... }

# Wildcard (requires DNS-01 ACME challenge, not HTTP-01)
*.yourdomain.com { ... }

# With environment variable (Docker pattern)
{$DOMAIN} { ... }

# Localhost / dev (Caddy uses its own CA, installs to system trust store)
localhost { ... }
```

---

## 3. Full Production Caddyfile

```caddyfile
{
    email admin@yourdomain.com

    servers {
        protocols h1 h2 h2c h3
    }

    log {
        level WARN
    }
}

yourdomain.com {

    # ── Compression ──────────────────────────────────────────────
    # zstd first (modern, faster), gzip fallback (universal)
    encode zstd gzip

    # ── Security headers ─────────────────────────────────────────
    header {
        # Force HTTPS for 2 years — add to browser preload list after testing
        Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"

        # Prevent MIME sniffing
        X-Content-Type-Options "nosniff"

        # Block clickjacking — use SAMEORIGIN if you embed in iframes
        X-Frame-Options "DENY"

        # Control referrer information
        Referrer-Policy "strict-origin-when-cross-origin"

        # Disable browser features you don't use
        Permissions-Policy "camera=(), microphone=(), geolocation=()"

        # Remove server fingerprint
        -Server

        # Remove Caddy's X-Powered-By if it appears
        -X-Powered-By
    }

    # ── Reverse proxy ─────────────────────────────────────────────
    reverse_proxy app:3000 {
        # Pass real client IP to app (important for logging + rate limiting)
        header_up X-Real-IP        {remote_host}
        header_up X-Forwarded-For  {remote_host}
        header_up X-Forwarded-Proto {scheme}

        # Strip sensitive internal headers from client requests
        header_up -X-Internal-Token

        # Active health checking — Caddy stops routing to unhealthy upstreams
        health_uri      /health
        health_interval 30s
        health_timeout  5s

        # Timeouts — tune based on your app's actual response times
        transport http {
            dial_timeout            5s
            response_header_timeout 30s
            read_timeout            60s
            write_timeout           60s
            # keepalive to upstream — reduces connection overhead
            keepalive               30s
            keepalive_idle_conns    10
        }
    }

    # ── Access log ────────────────────────────────────────────────
    log {
        output file /data/access.log {
            roll_size 10mb
            roll_keep 5
        }
        format json    # structured logs — easier to parse / ship to log aggregator
    }
}

# ── www → apex redirect ───────────────────────────────────────────
www.yourdomain.com {
    redir https://yourdomain.com{uri} permanent
}
```

---

## 4. Content-Security-Policy

CSP deserves its own section because it's the header most likely to break your app.

```caddyfile
# ── Start permissive, tighten iteratively ────────────────────

# Phase 1: Report-only (collects violations, blocks nothing)
header Content-Security-Policy-Report-Only "default-src 'self'; report-uri /csp-report"

# Phase 2: Strict (breaks most apps that use CDN scripts or inline styles)
header Content-Security-Policy "default-src 'self'"

# Phase 3: Realistic production CSP for a typical web app
header Content-Security-Policy "
  default-src 'self';
  script-src  'self' https://cdn.jsdelivr.net;
  style-src   'self' 'unsafe-inline' https://fonts.googleapis.com;
  font-src    'self' https://fonts.gstatic.com;
  img-src     'self' data: https:;
  connect-src 'self' https://api.yourdomain.com;
  frame-ancestors 'none'
"
```

> **Never deploy a strict CSP without testing it first.**
> `Content-Security-Policy-Report-Only` lets you see what would break
> without actually blocking anything. Use it for a week before enforcing.

---

## 5. Routing Patterns

### Static files

```caddyfile
yourdomain.com {
    # Serve static files from a directory
    root * /var/www/html

    # Try file first, fall back to index.html (SPA pattern)
    try_files {path} /index.html

    file_server
}
```

### API + SPA split

```caddyfile
yourdomain.com {
    # API requests → backend
    handle /api/* {
        reverse_proxy backend:8080
    }

    # Everything else → frontend static files
    handle {
        root * /var/www/dist
        try_files {path} /index.html
        file_server
    }
}
```

### Multiple backends on one domain

```caddyfile
yourdomain.com {
    # Route by path prefix to different services
    handle /api/v1/* {
        reverse_proxy api_v1:3000
    }

    handle /api/v2/* {
        reverse_proxy api_v2:4000
    }

    handle /auth/* {
        reverse_proxy auth_service:5000
    }

    handle {
        reverse_proxy frontend:8080
    }
}
```

### Multiple domains → multiple apps

```caddyfile
# Each domain block is independent
app1.com {
    reverse_proxy webapp1:3000
}

app2.com {
    reverse_proxy webapp2:4000
}

api.yourdomain.com {
    reverse_proxy api_service:8080
}
```

### Basic auth (quick protection for staging)

```caddyfile
staging.yourdomain.com {
    basicauth {
        # Generate with: caddy hash-password
        alice $2a$14$Zkx19XLiW6VYouLHR5NmfOFU0z2GTNmpkT/5qqR7hx4IjWJPDhjvG
    }
    reverse_proxy staging_app:3000
}
```

### Custom error pages

```caddyfile
yourdomain.com {
    reverse_proxy app:3000

    handle_errors {
        @404 expression {http.error.status_code} == 404
        handle @404 {
            rewrite * /404.html
            file_server {
                root /var/www/errors
            }
        }

        @5xx expression {http.error.status_code} >= 500
        handle @5xx {
            respond "Service temporarily unavailable" 503
        }
    }
}
```

---

## 6. TLS / HTTPS

### Automatic (default — just use a domain name)

```caddyfile
# Caddy sees a hostname → automatically gets a certificate
yourdomain.com {
    reverse_proxy app:3000
}
```

Caddy handles: ACME HTTP-01 challenge → certificate issuance → renewal →
OCSP stapling. No certbot, no cron, no manual renewal.

### Rate limits — Let's Encrypt

Let's Encrypt enforces: **5 duplicate certificates per domain per week**.

To avoid hitting this:
- ✅ Always persist `caddy_data` volume — never delete it casually
- ✅ Use staging CA during development/testing
- ✅ Use ZeroSSL as alternative issuer if you hit LE limits

```caddyfile
# Use staging CA (issues untrusted certs — for testing only)
{
    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
}
```

### Manual certificate (if you have your own)

```caddyfile
yourdomain.com {
    tls /path/to/cert.pem /path/to/key.pem
    reverse_proxy app:3000
}
```

### Internal HTTPS (localhost / LAN)

```caddyfile
# Caddy uses its own CA, installs cert to system trust store
# Run: caddy trust  (installs Caddy's root CA)
localhost {
    reverse_proxy app:3000
}

192.168.1.100 {
    tls internal
    reverse_proxy app:3000
}
```

### HSTS — enable carefully

```caddyfile
header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
```

> ⚠️ **HSTS is a one-way door.** Once a browser sees this header, it will
> refuse to connect over HTTP for `max-age` seconds (here: 2 years).
> If you ever need to serve HTTP (e.g., during a certificate failure), browsers
> will refuse to connect.
>
> Steps before enabling `preload`:
> 1. Test with `max-age=300` (5 minutes) first
> 2. Confirm HTTPS works perfectly for all subdomains
> 3. Increase to full value
> 4. Only add to the HSTS preload list when you're certain you'll never need HTTP

---

## 7. Performance

### Compression

```caddyfile
# zstd is ~30% faster than gzip at same compression ratio
# gzip is the fallback for older clients
encode zstd gzip
```

### HTTP/3 (QUIC)

```caddyfile
# In global options
servers {
    protocols h1 h2 h2c h3
}
```

Requires `443:443/udp` port mapping in Docker. HTTP/3 uses QUIC (UDP-based),
which recovers better from packet loss — noticeably faster on mobile networks.

### Upstream keepalive

```caddyfile
reverse_proxy app:3000 {
    transport http {
        keepalive          30s
        keepalive_idle_conns 10    # maintain connection pool to upstream
    }
}
```

Without keepalive, every proxied request opens a new TCP connection to your
upstream. With keepalive, connections are reused — meaningful latency reduction
under load.

### Load balancing (multiple upstreams)

```caddyfile
reverse_proxy app1:3000 app2:3000 app3:3000 {
    # Policies: round_robin (default), least_conn, random, first, ip_hash
    lb_policy least_conn

    health_uri      /health
    health_interval 10s
}
```

---

## 8. Logging

```caddyfile
yourdomain.com {
    log {
        output file /data/access.log {
            roll_size 10mb
            roll_keep 5            # keeps last 50MB of logs
            roll_keep_for 720h     # delete logs older than 30 days
        }
        format json               # structured — pipe to ELK, Loki, etc.
        level  INFO
    }
}
```

### What the JSON log format looks like

```json
{
  "ts": 1709123456.789,
  "request": {
    "method": "GET",
    "uri": "/api/users",
    "proto": "HTTP/2.0",
    "remote_addr": "1.2.3.4:54321",
    "host": "yourdomain.com"
  },
  "status": 200,
  "size": 1234,
  "duration": 0.045,
  "user_agent": "Mozilla/5.0..."
}
```

### Access logs in Docker

```bash
# Follow Caddy logs
docker logs -f caddy_proxy

# Read the structured access log
docker exec caddy_proxy cat /data/access.log | jq .

# Filter for errors only
docker exec caddy_proxy cat /data/access.log | jq 'select(.status >= 400)'
```

---

## 9. Config Reload & Validation

```bash
# ── Docker ────────────────────────────────────────────────────

# Validate Caddyfile syntax before reloading (dry run)
docker exec caddy_proxy caddy validate --config /etc/caddy/Caddyfile

# Reload config — zero downtime, no connection drops
docker exec caddy_proxy caddy reload --config /etc/caddy/Caddyfile

# Force full restart (only if reload doesn't work)
docker compose restart caddy

# ── System install ────────────────────────────────────────────

# Validate
caddy validate --config /etc/caddy/Caddyfile

# Reload (zero-downtime — sends SIGUSR1 to the process)
sudo systemctl reload caddy
# or
caddy reload --config /etc/caddy/Caddyfile

# Full restart
sudo systemctl restart caddy

# ── Caddy API (for programmatic config) ───────────────────────
# Caddy exposes a REST API at localhost:2019
curl -s http://localhost:2019/config/ | jq .
```

> **Always validate before reload**. A syntax error in the Caddyfile will
> cause the reload to fail — but Caddy keeps serving the old config, so there
> is no downtime. Still, catching the error before applying is better.

---

## 10. Caddy API & Dynamic Config

Caddy has a built-in REST API on port 2019 for dynamic configuration changes
without touching the Caddyfile. Useful for automation and config-as-code.

```bash
# Get current config
curl http://localhost:2019/config/

# Add a new route dynamically
curl -X POST http://localhost:2019/config/apps/http/servers/srv0/routes \
  -H "Content-Type: application/json" \
  -d '{ ... }'

# Load an entirely new config
curl -X POST http://localhost:2019/load \
  -H "Content-Type: text/caddyfile" \
  --data-binary @/path/to/Caddyfile
```

> In Docker, the API is not exposed by default. Only expose port 2019 on
> `127.0.0.1` if you need it, never on `0.0.0.0`.

---

## 11. Useful Caddy Commands

```bash
# Format and lint Caddyfile (fixes indentation, detects errors)
caddy fmt --overwrite /etc/caddy/Caddyfile

# List all loaded modules
caddy list-modules

# Check what version + modules are compiled in
caddy version
caddy build-info

# Generate a hashed password for basicauth
caddy hash-password --plaintext "mypassword"

# Run in foreground with verbose logging (debugging)
caddy run --config /etc/caddy/Caddyfile --watch

# Trust Caddy's local CA (for localhost HTTPS in dev)
caddy trust
```

---

## 12. Custom Builds (Adding Plugins)

The official `caddy:alpine` image does not include community plugins.
For plugins like rate limiting, DNS-01 challenges, or dynamic DNS, build a
custom image using `xcaddy`:

```dockerfile
FROM caddy:2.8.4-builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-ratelimit

FROM caddy:2.8.4-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```

Common plugins:
| Plugin | Use |
|---|---|
| `caddy-dns/cloudflare` | DNS-01 ACME for wildcard certs via Cloudflare |
| `caddy-dns/route53` | DNS-01 via AWS Route53 |
| `mholt/caddy-ratelimit` | Per-IP rate limiting |
| `greenpau/caddy-security` | OAuth2, JWT, SSO |
| `caddyserver/ntlm-transport` | Windows NTLM proxy |

---

## Quick Checklist

- [ ] Global block has `email` set (Let's Encrypt notifications)
- [ ] `protocols h1 h2 h2c h3` + `443:443/udp` for HTTP/3
- [ ] `caddy_data` is a named volume — never bind-mount certificates
- [ ] `encode zstd gzip` enabled
- [ ] Security headers block present
- [ ] `-Server` header removes server fingerprint
- [ ] HSTS tested with short `max-age` before setting to 2 years
- [ ] CSP tested in Report-Only mode before enforcing
- [ ] Health check configured on `reverse_proxy`
- [ ] Upstream `keepalive` configured
- [ ] Access log with `roll_size` and `roll_keep` to prevent disk fill
- [ ] `caddy validate` runs before every reload
- [ ] Staging ACME CA used during development (not burning LE rate limits)
- [ ] `www.` redirect configured
- [ ] Caddyfile mounted `:ro` in Docker
