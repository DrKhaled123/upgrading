# Docker Best Practices — Production Reference
## Docker alone: images, containers, compose, security, operations

---

## 1. Image Building

### Always use multi-stage builds

```dockerfile
# ── Stage 1: Build ────────────────────────────────────────────
FROM node:20.11.0-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci && npm cache clean --force
COPY . .
RUN npm run build

# ── Stage 2: Production ───────────────────────────────────────
FROM node:20.11.0-alpine AS production
RUN addgroup -g 1001 appgroup && \
    adduser  -u 1001 -G appgroup -s /bin/sh -D appuser
WORKDIR /app
COPY --from=builder --chown=appuser:appgroup /app/dist        ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/package.json ./
USER appuser
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**Why**: The builder stage includes compilers, dev dependencies, and build tools
that have no place in production. A typical Node app drops from 800MB → ~120MB.
Go apps can reach under 10MB. Smaller images = smaller attack surface + faster pulls.

### Pin exact base image versions

```dockerfile
# ❌ Bad — non-reproducible, silent upstream breaks
FROM node:20-alpine
FROM python:3-slim
FROM postgres:latest

# ✅ Good — reproducible, auditable
FROM node:20.11.0-alpine
FROM python:3.12.2-slim-bookworm
FROM postgres:16.2-alpine
```

Floating tags (`20-alpine`, `latest`) can silently change between builds.
Pin to exact minor+patch versions. Review and bump deliberately.

### Layer cache order: least-changed → most-changed

```dockerfile
# ❌ Bad — source code change invalidates dependency cache
COPY . .
RUN npm ci

# ✅ Good — dependency layer only rebuilds when package.json changes
COPY package*.json ./
RUN npm ci
COPY . .
```

Docker invalidates all layers below the first changed layer. Put slow,
stable operations (dependency installs) before fast, frequent ones (source copy).

### Never run as root

```dockerfile
# Create a dedicated user — never use root or the default container user
RUN addgroup -g 1001 appgroup && \
    adduser  -u 1001 -G appgroup -s /bin/sh -D appuser
USER appuser
```

If an attacker exploits your app and escapes the process, they land as an
unprivileged user instead of root. This is not optional for production.

### .dockerignore — keep build context small

```dockerignore
.git
.env
.env.*
*.md
docker-compose*.yml
data/
node_modules/
__pycache__/
*.pyc
.venv/
.vscode/
.idea/
coverage/
dist/          # if built outside Docker
*.log
*.test.*
```

Without `.dockerignore`, Docker sends your entire project directory
(including node_modules, .git history, secrets) to the build daemon.
This leaks secrets into image layers and makes builds slow.

### HEALTHCHECK in Dockerfile

```dockerfile
# HTTP app
HEALTHCHECK --interval=30s --timeout=5s --retries=3 --start-period=15s \
    CMD wget --spider -q http://localhost:3000/health || exit 1

# TCP-only app (no HTTP)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD nc -z localhost 3000 || exit 1
```

A container can be "running" with a completely crashed process inside it.
Without a health check, orchestrators and `depends_on: condition: service_healthy`
cannot detect this. Docker sets the container status to `unhealthy` — you can
alert on this and auto-restart.

---

## 2. Docker Compose

### Full production-grade `docker-compose.yml`

```yaml
services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile
      args:
        - APP_VERSION=${APP_VERSION:-latest}
    image: myapp:${APP_VERSION:-latest}   # tag built image for rollback
    container_name: myapp
    restart: unless-stopped
    networks:
      - web
      - backend
    expose:
      - "3000"
    env_file:
      - .env
    environment:
      - NODE_ENV=production              # explicit; don't rely solely on .env
    volumes:
      - app_uploads:/app/uploads
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 15s
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 512M
        reservations:
          cpus: "0.25"
          memory: 128M
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "5"
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /app/tmp
    depends_on:
      db:
        condition: service_healthy     # waits for DB health check before starting

  db:
    image: postgres:16.2-alpine
    container_name: myapp_db
    restart: unless-stopped
    networks:
      - backend
    expose:
      - "5432"
    env_file:
      - .env
    environment:
      POSTGRES_DB:       ${DB_NAME}
      POSTGRES_USER:     ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 1G
    security_opt:
      - no-new-privileges:true

networks:
  web:
    name: web_network
  backend:
    name: backend_network
    internal: true    # no outbound internet, no inbound from outside Docker

volumes:
  app_uploads:
  db_data:
```

### `restart` policy — choose correctly

| Policy | Behavior | Use when |
|---|---|---|
| `no` | never restarts | dev only |
| `always` | always restarts, including on manual stop | bad choice |
| `unless-stopped` | restarts on crash/reboot, respects manual stop | **production default** |
| `on-failure` | restarts only on non-zero exit | batch jobs |

`always` ignores your intent when you manually stop for maintenance — the
container comes back on next daemon start even though you explicitly stopped it.

### `expose` vs `ports` — the most misunderstood distinction

```yaml
# expose: visible inside Docker networks only — NOT reachable from host
expose:
  - "3000"

# ports: binds to host network interface — publicly reachable
# Docker writes iptables rules that BYPASS UFW/firewalld
ports:
  - "3000:3000"    # 0.0.0.0:3000 — exposed to the entire internet
  - "127.0.0.1:3000:3000"  # localhost only — safer if you must use ports
```

**Only bind `ports` for services that must be publicly accessible** (e.g., your
reverse proxy on 80/443). For everything else — app servers, databases, caches —
use `expose` and let them communicate over Docker networks.

### Network segmentation

```yaml
networks:
  web:                    # reverse proxy ↔ app
    name: web_network
  backend:
    name: backend_network
    internal: true        # app ↔ database, no internet access
```

- `web` network: proxy + app only
- `backend` network (internal): app + database only
- The proxy has **no path** to the database at all

`internal: true` means containers on that network cannot initiate outbound
internet connections and cannot be reached from outside. Critical for databases.

### Environment variable handling

```yaml
# ❌ Bad — secrets in compose file, committed to git
environment:
  - DB_PASSWORD=supersecret

# ✅ Good — loaded from .env file, never committed
env_file:
  - .env
environment:
  - NODE_ENV=production    # non-secret overrides are fine inline
```

```bash
# .env — NEVER commit this
DB_PASSWORD=supersecret

# .env.example — commit this as a template
DB_PASSWORD=replace-with-strong-password
```

```bash
# Generate strong secrets
openssl rand -hex 32
openssl rand -base64 48
```

Add to `.gitignore` immediately:
```
.env
.env.*
!.env.example
```

### Dev/prod separation

```
docker-compose.yml           # base — shared config
docker-compose.override.yml  # local dev — auto-loaded, git-ignored
docker-compose.prod.yml      # production overrides
```

```yaml
# docker-compose.override.yml (dev)
services:
  app:
    volumes:
      - ./app:/app    # live code reload in dev
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"   # direct access in dev is fine
```

```bash
# dev (auto-merges override.yml)
docker compose up

# production (explicit prod file)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## 3. Security

### `no-new-privileges:true`

```yaml
security_opt:
  - no-new-privileges:true
```

Prevents processes inside the container from gaining additional privileges
via setuid binaries or file capabilities. Always set this.

### Read-only filesystem + tmpfs

```yaml
read_only: true
tmpfs:
  - /tmp
  - /app/tmp    # wherever your app writes temp files
```

A read-only container filesystem prevents an attacker who compromises your app
from modifying binaries or writing persistent backdoors inside the container.
Use `tmpfs` for directories that legitimately need writes — they're in-memory,
gone on container restart, and not part of the image.

### Resource limits — mandatory, not optional

```yaml
deploy:
  resources:
    limits:
      cpus: "1.0"
      memory: 512M
    reservations:
      cpus: "0.25"
      memory: 128M
```

Without limits, a single container can consume all VPS CPU/memory and crash
the entire server. Set limits based on real usage — monitor first, then set
limits at ~2× observed peak.

### Log rotation — without this, your disk will fill

```yaml
logging:
  driver: json-file
  options:
    max-size: "10m"
    max-file: "5"    # keeps last 50MB of logs per container
```

Set this globally in `/etc/docker/daemon.json` so every container inherits it:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  }
}
```

Without log rotation, a chatty container (or one that encounters an error loop)
will eventually consume all disk space and crash your server.

---

## 4. Docker Daemon (`/etc/docker/daemon.json`)

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "5"
  },
  "storage-driver": "overlay2",
  "live-restore": true,
  "no-new-privileges": true,
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 65536,
      "Soft": 32768
    }
  }
}
```

```bash
sudo systemctl restart docker
```

**`live-restore: true`** — keeps containers running during Docker daemon
upgrades. You can patch Docker itself without any container downtime.

**`userns-remap`** — maps container root to unprivileged host user.
Meaningful security improvement. Honest tradeoff:
- ✅ container escape lands as nobody on the host
- ❌ breaks volume permissions for Postgres, Redis, many others
- ❌ requires manual `chown` of all volume paths
- ❌ incompatible with some images
Recommended only if your team understands the tradeoff. Running containers
as non-root via `USER` in Dockerfile covers most of the same ground.

---

## 5. Volumes

```yaml
volumes:
  # ✅ Named volume — Docker manages location, survives compose down
  db_data:
  app_uploads:

# ✅ Bind mount — for config files, source code in dev
volumes:
  - ./Caddyfile:/etc/caddy/Caddyfile:ro
  - ./app:/app    # dev only

# ❌ Never bind-mount source code in production
# It bypasses your Dockerfile entirely and exposes source inside container
```

| Volume type | Use for | Don't use for |
|---|---|---|
| Named volume | database data, certificates, uploads | config files |
| Bind mount (`:ro`) | config files fed into containers | app source in prod |
| `tmpfs` | temp files, caches, scratch | anything that must persist |

---

## 6. Deployment Workflow

```bash
#!/bin/bash
# deploy.sh
set -euo pipefail

APP_VERSION=$(git rev-parse --short HEAD)
export APP_VERSION

echo "==> Building image (version: $APP_VERSION)..."
docker compose build --no-cache    # build FIRST — fail before touching live

echo "==> Running migrations..."
docker compose run --rm app npm run db:migrate

echo "==> Deploying..."
docker compose up -d --remove-orphans

echo "==> Pruning old images..."
docker image prune -f

echo "==> Health check (waiting 15s)..."
sleep 15
if curl -sf http://localhost:3000/health > /dev/null; then
    echo "✅ Deploy succeeded — version $APP_VERSION"
else
    echo "❌ Health check failed — rolling back"
    git checkout HEAD~1
    docker compose build
    docker compose up -d
    exit 1
fi
```

> Always build then up as **separate steps**. `docker compose up -d --build`
> in a single command will leave you with stopped containers if the build
> fails halfway — no fallback.

---

## 7. Maintenance (crontab)

```bash
crontab -e
```

```cron
# Prune unused Docker resources — weekly Sunday 3 AM
# --filter "until=168h" protects images younger than 1 week
0 3 * * 0 docker system prune -af --volumes --filter "until=168h" >> /var/log/docker-prune.log 2>&1

# Database backup — daily 2 AM
0 2 * * * docker exec myapp_db pg_dump -U ${DB_USER} ${DB_NAME} | gzip > /backups/db_$(date +\%Y\%m\%d).sql.gz

# Delete backups older than 30 days
0 4 * * * find /backups -name "db_*.sql.gz" -mtime +30 -delete
```

---

## 8. Useful Commands

```bash
# Live resource usage per container
docker stats

# Inspect environment variables (shows secrets — be careful)
docker inspect myapp | grep -A 20 '"Env"'

# Shell into running container (use sh not bash on alpine)
docker exec -it myapp sh

# Follow logs
docker logs -f myapp
docker compose logs -f app

# Check health status
docker inspect --format='{{.State.Health.Status}}' myapp

# Remove everything (nuclear option — DESTROYS named volumes)
docker system prune -af --volumes

# Remove only stopped containers + dangling images (safe)
docker system prune -f

# List all networks
docker network ls

# See which containers are on a network
docker network inspect web_network
```

---

## Quick Checklist

- [ ] Multi-stage Dockerfile — no build tools in production image
- [ ] Exact base image version pinned
- [ ] `USER nonroot` — never run as root
- [ ] `.dockerignore` — secrets excluded from build context
- [ ] `HEALTHCHECK` defined in Dockerfile
- [ ] `expose` not `ports` for app/db containers
- [ ] `internal: true` on backend network
- [ ] `restart: unless-stopped`
- [ ] `no-new-privileges: true`
- [ ] `read_only: true` + `tmpfs` for /tmp
- [ ] Resource limits (`cpus`, `memory`)
- [ ] Log rotation (`max-size`, `max-file`)
- [ ] `.env` in `.gitignore`, `.env.example` committed
- [ ] `daemon.json` configured with `live-restore` + default log limits
- [ ] Deployment builds before switching — no single-step `up --build`
- [ ] Database backups scheduled and tested
