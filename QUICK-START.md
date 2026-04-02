# ⚡ Quick Start Guide

## Installation

```bash
# Clone this repo
git clone https://github.com/DrKhaled123/upgrading.git
cd upgrading

# Or deploy to server
./deploy-to-server.sh root@your-server.com ~/.ssh/your-key
```

## Daily Usage

### 1. Bug Fixing
```bash
# Read the system
cat prompts/01-bug-fixation-system.md | less

# Use with Kimi:
# @01-bug-fixation-system.md Fix this error: [paste]
```

### 2. Code Review
```bash
# Review principles
cat prompts/02-code-quality-excellence.md | head -100

# Use with Kimi:
# @02-code-quality-excellence.md Review this: [paste code]
```

### 3. Testing
```bash
# Testing strategies
cat prompts/03-testing-strategies.md | grep -A 5 "5-Tier"

# Use with Kimi:
# @03-testing-strategies.md Write tests for: [paste function]
```

### 4. Deployment
```bash
# Copy configs
cp tools/devops/ecosystem.config.js /your/app/
cp tools/devops/Caddyfile /etc/caddy/

# Use with Kimi:
# @04-free-tools-devops.md Setup PM2 + Caddy for my app
```

## Memory Aid

**Remember: "1 bug, 2 review, 3 test, 4 deploy"**

| # | File | Keyword |
|---|------|---------|
| 1 | Bug Fixation | 🐛 Broken |
| 2 | Code Quality | ✨ Clean |
| 3 | Testing | 🧪 Verify |
| 4 | DevOps | 🚀 Ship |
| 5 | Changes | 📋 Docs |

## Server Shortcuts

After deploying to server, create these aliases:

```bash
# Add to ~/.bashrc or ~/.zshrc
alias ai-bug='cat ~/upgrading/prompts/01-bug-fixation-system.md | less'
alias ai-review='cat ~/upgrading/prompts/02-code-quality-excellence.md | less'
alias ai-test='cat ~/upgrading/prompts/03-testing-strategies.md | less'
alias ai-deploy='cat ~/upgrading/prompts/04-free-tools-devops.md | less'
```
