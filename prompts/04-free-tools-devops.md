# Free Tools & DevOps Strategies (2025 Enhanced)
> **Purpose:** Zero-cost toolkit for development, testing, and deployment  
> **Scope:** Local development to production deployment  
> **Requirement:** No credentials, no paid services, fully open-source

---

## 🎯 ZERO-COST TOOLKIT OVERVIEW

```
┌─────────────────────────────────────────────────────────────────┐
│                    FREE TOOL ECOSYSTEM                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  DEVELOPMENT        TESTING          DEPLOYMENT        MONITORING│
│  ───────────        ───────          ──────────        ──────────│
│  • VS Code          • Jest           • Docker          • PM2    │
│  • ESLint           • Pytest         • Caddy           • Netdata│
│  • Prettier         • Playwright     • PM2             • Uptime │
│  • Git              • k6             • Systemd         • Grafana│
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## PART 1: DEVELOPMENT TOOLS

### Code Quality & Linting

**ESLint (JavaScript/TypeScript)**
```bash
# Installation
npm install --save-dev eslint @eslint/js

# Configuration (.eslintrc.json)
{
  "extends": ["eslint:recommended"],
  "rules": {
    "no-unused-vars": "error",
    "no-console": "warn",
    "eqeqeq": "error"
  }
}

# Usage
npx eslint . --ext .js,.jsx,.ts,.tsx
```

**Prettier (Universal Formatter)**
```bash
# Installation
npm install --save-dev prettier

# Configuration (.prettierrc)
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}

# Usage
npx prettier --write "src/**/*.{js,ts,css,json}"
```

**Pylint (Python)**
```bash
# Installation
pip install pylint

# Usage
pylint --output-format=colorized src/

# Configuration (.pylintrc)
[MESSAGES CONTROL]
disable=C0111,R0903

[FORMAT]
max-line-length=100
```

---

### Static Analysis (Security)

**Semgrep (Multi-language)**
```bash
# Installation
pip install semgrep

# Usage
semgrep --config=auto --error src/

# Custom rules
semgrep --config .semgrep.yml src/
```

**Bandit (Python Security)**
```bash
# Installation
pip install bandit

# Usage
bandit -r src/ -f json -o bandit-report.json

# Severity filtering
bandit -r src/ -lll  # Only high severity
```

**Gosec (Go Security)**
```bash
# Installation
go install github.com/securego/gosec/v2/cmd/gosec@latest

# Usage
gosec ./...
```

---

### Deep Static Analysis

**Facebook Infer**
```bash
# Installation
brew install infer  # macOS
# OR download binary from GitHub

# Usage
infer run -- make build

# View results
infer explore  # Interactive
```

**CodeQL (GitHub)**
```bash
# Installation
codeql pack install

# Database creation
codeql database create --language=javascript db

# Analysis
codeql analyze db security-extended --format=sarif --output=results.sarif
```

---

## PART 2: DYNAMIC ANALYSIS

### Memory & Runtime Analysis

**Valgrind (C/C++)**
```bash
# Installation
sudo apt-get install valgrind  # Ubuntu/Debian

# Memory leak detection
valgrind --leak-check=full --show-leak-kinds=all ./program

# Call profiling
valgrind --tool=callgrind ./program
```

**AddressSanitizer (Any language with compiler support)**
```bash
# Compilation with ASan
clang -fsanitize=address -g program.c -o program

# Run - crashes on memory errors
./program
```

**Node.js Memory Profiling**
```bash
# Heap snapshot
node --heap-prof app.js

# Analyze with Chrome DevTools
# 1. Run with inspect
node --inspect-brk app.js
# 2. Open chrome://inspect in Chrome
```

---

### Fuzzing

**AFL++ (C/C++)**
```bash
# Installation
sudo apt-get install afl++

# Compile target
afl-cc -o target target.c

# Run fuzzing
afl-fuzz -i input_dir -o output_dir -- ./target @@

# Check crashes
ls output_dir/crashes/
```

**JSfuzz (JavaScript)**
```bash
# Installation
npm install -g jsfuzz

# Fuzz target
jsfuzz fuzz-target.js
```

---

## PART 3: TESTING TOOLS

### Unit Testing

**Jest (JavaScript)**
```bash
# Installation
npm install --save-dev jest

# Configuration (jest.config.js)
module.exports = {
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
};

# Run with coverage
npx jest --coverage
```

**Pytest (Python)**
```bash
# Installation
pip install pytest pytest-cov

# Run with coverage
pytest --cov=src --cov-report=html --cov-report=term
```

---

### E2E Testing

**Playwright**
```bash
# Installation
npm install --save-dev @playwright/test
npx playwright install

# Run tests
npx playwright test

# Generate report
npx playwright show-report
```

**Configuration (playwright.config.js)**
```javascript
module.exports = {
  testDir: './tests',
  fullyParallel: true,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html'], ['json', { outputFile: 'results.json' }]],
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure'
  }
};
```

---

### Load Testing

**k6**
```bash
# Installation (Docker - no install needed)
docker run -v $(pwd):/app loadimpact/k6 run /app/load-test.js

# OR install locally
brew install k6

# Test script
```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 }, // Ramp up
    { duration: '5m', target: 100 }, // Steady state
    { duration: '2m', target: 200 }, // Spike
    { duration: '5m', target: 200 }, // Sustained load
    { duration: '2m', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% under 500ms
    http_req_failed: ['rate<0.01'],   // <1% errors
  },
};

export default function () {
  const res = http.get('http://localhost:3000/api/users');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
```

---

## PART 4: DEPLOYMENT TOOLS

### Containerization

**Docker**
```dockerfile
# Multi-stage build for optimization
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

**Docker Compose**
```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
      - redis
    restart: unless-stopped
    
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
      
  redis:
    image: redis:7-alpine
    command: redis-server --maxmemory 256mb
    
volumes:
  pgdata:
```

---

### Web Servers & Reverse Proxies

**Caddy (Easiest HTTPS)**
```caddyfile
# Caddyfile
example.com {
    reverse_proxy localhost:3000
    
    # Automatic HTTPS - Zero config needed!
    
    # Compression
    encode gzip zstd
    
    # Logging
    log {
        output file /var/log/caddy/access.log
    }
}
```

**Why Caddy?**
- Automatic HTTPS with Let's Encrypt
- Zero configuration SSL certificates
- Built-in HTTP/3 (QUIC) support
- Simple, readable configuration syntax

---

### Process Management

**PM2 (Node.js)**
```bash
# Installation
npm install -g pm2

# Start with config
pm2 start ecosystem.config.js

# Configuration (ecosystem.config.js)
module.exports = {
  apps: [{
    name: 'my-app',
    script: './server.js',
    instances: 'max',      # Use all CPU cores
    exec_mode: 'cluster',  # Enable clustering
    max_memory_restart: '500M',
    env: { NODE_ENV: 'production' },
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    error_file: './logs/err.log',
    out_file: './logs/out.log',
    merge_logs: true,
    # Auto-restart
    autorestart: true,
    max_restarts: 10,
    min_uptime: '10s'
  }]
};

# Monitoring
pm2 monit
pm2 logs
```

**Systemd (Universal)**
```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/var/www/myapp
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
```

```bash
# Enable and start
sudo systemctl enable myapp
sudo systemctl start myapp
sudo systemctl status myapp
```

---

## PART 5: MONITORING & OBSERVABILITY

### Application Monitoring

**PM2 Monitoring**
```bash
# Built-in monitoring
pm2 monit

# Plus (free tier)
pm2 plus
```

**Netdata (System Monitoring)**
```bash
# Installation
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

# Access
http://localhost:19999

# Features:
# - Real-time metrics
# - 100+ integrations
# - Alerts
# - No config needed
```

---

### Uptime Monitoring

**UptimeRobot (Free Tier)**
```
- 50 monitors
- 5-minute intervals
- Email alerts
- Public status pages
```

**Freshping**
```
- Unlimited monitors
- 1-minute intervals
- Multi-channel alerts
```

---

### Log Management

**Journald (Systemd)**
```bash
# View logs
journalctl -u myapp -f

# Recent errors
journalctl -u myapp --since "1 hour ago" --priority=err

# Export
journalctl -u myapp --since "2024-01-01" > app-logs.txt
```

**Grafana Loki (Lightweight)**
```yaml
# docker-compose.yml
services:
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./loki-config.yml:/etc/loki/config.yml
      - loki-data:/loki
      
  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log:ro
      - ./promtail-config.yml:/etc/promtail/config.yml
```

---

### Metrics & Alerting

**Grafana + Prometheus**
```yaml
# docker-compose.yml
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana-data:/var/lib/grafana
```

**Prometheus Config**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
        
  - job_name: 'myapp'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: '/metrics'
```

---

## PART 6: DATABASE TOOLS

### Administration

**pgAdmin (PostgreSQL)**
```bash
# Docker run
docker run -p 5050:80 \
  -e PGADMIN_DEFAULT_EMAIL=admin@example.com \
  -e PGADMIN_DEFAULT_PASSWORD=admin \
  dpage/pgadmin4
```

**Adminer (Universal)**
```bash
# Single file, any database
docker run -p 8080:8080 adminer

# Supports: MySQL, PostgreSQL, SQLite, MongoDB, etc.
```

---

### Migration Tools

**Flyway**
```bash
# Installation
brew install flyway

# Migrate
flyway -url=jdbc:postgresql://localhost/mydb \
       -user=myuser \
       -password=mypass \
       migrate
```

---

## PART 7: COMPLETE WORKFLOW EXAMPLE

### Local Development Setup

```bash
# 1. Code quality
npx eslint . && npx prettier --check .

# 2. Static analysis
npx semgrep --config=auto

# 3. Unit tests
npx jest --coverage

# 4. Integration tests
npx jest --config=jest.integration.config.js

# 5. E2E tests
npx playwright test

# 6. Build
docker build -t myapp:latest .

# 7. Local deployment
docker-compose up -d

# 8. Smoke tests
curl http://localhost:3000/health

# 9. Load test
npx k6 run load-test.js
```

### Production Deployment

```bash
# 1. Deploy with zero downtime
docker-compose up -d --no-deps --build app

# 2. Health check
for i in {1..10}; do
  curl -f http://localhost:3000/health && break
  sleep 2
done

# 3. Monitor logs
docker-compose logs -f app

# 4. Verify metrics
pm2 monit

# 5. Setup alerts
# Configure UptimeRobot or Freshping
```

---

## TOOL SELECTION QUICK REFERENCE

| Task | Recommended Tool | Alternative |
|------|------------------|-------------|
| **Linting** | ESLint/Pylint | StandardJS, Black |
| **Formatting** | Prettier | autopep8 |
| **Security Scan** | Semgrep | SonarQube Community |
| **Unit Testing** | Jest/Pytest | Mocha, unittest |
| **E2E Testing** | Playwright | Cypress |
| **Load Testing** | k6 | Artillery |
| **Containerization** | Docker | Podman |
| **Web Server** | Caddy | Traefik |
| **Process Manager** | PM2 | Systemd |
| **Monitoring** | Netdata | Prometheus+Grafana |
| **Uptime** | UptimeRobot | Freshping |
| **Logs** | Loki | Journald |

---

## UPGRADES FROM ORIGINAL

### Key Improvements:

1. **Docker Integration**
   - Containerization for all tools
   - Compose configurations
   - Multi-stage builds

2. **Production-Ready Configs**
   - PM2 ecosystem files
   - Systemd services
   - Caddy configs (simpler alternative)

3. **Complete Workflows**
   - Local development pipeline
   - Production deployment steps
   - Health checks

4. **Simplified Deployment**
   - Caddy (automatic HTTPS, simpler config)
   - PM2 for process management
   - Docker Compose for orchestration

5. **Monitoring Stack**
   - Netdata for quick setup
   - Prometheus/Grafana for advanced
   - Uptime monitoring

6. **Tool Selection Guide**
   - Quick reference table
   - Primary + alternatives
   - Use case matching

---

## REMOVED CONTENT (Due to Error-Prone Complexity)

The following tools were intentionally removed from this guide based on reported implementation difficulties:

- **Coolify** - Self-hosted PaaS requiring complex container orchestration
- **Nginx** - Verbose configuration replaced with simpler Caddy alternative  
- **CI/CD Pipelines** - Error-prone automation requiring expert-level troubleshooting

**Recommendation:** Use PM2 + Caddy + Docker Compose for reliable, simple deployment without the complexity overhead.

---

> **Version:** 2.1 (2025)  
> **Status:** Production-Ready  
> **Cost:** $0 (all open-source)  
> **Use:** Complete development-to-production toolchain
