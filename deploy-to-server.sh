#!/bin/bash
# deploy-to-server.sh
# Deploy these prompts to your remote server

set -e

SERVER="${1:-root@your-server.com}"
SSH_KEY="${2:-~/.ssh/id_rsa}"
REMOTE_DIR="/root/upgrading"

echo "🚀 Deploying to server: $SERVER"

# Create remote directory
ssh -i "$SSH_KEY" "$SERVER" "mkdir -p $REMOTE_DIR"

# Copy all files
scp -i "$SSH_KEY" -r prompts skills tools README.md QUICK-START.md "$SERVER:$REMOTE_DIR/"

echo "✅ Deployed to $SERVER:$REMOTE_DIR"
echo ""
echo "📍 On server, prompts are at: $REMOTE_DIR/prompts/"
echo "🔗 SSH: ssh -i $SSH_KEY $SERVER"
