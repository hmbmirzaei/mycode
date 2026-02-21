#!/bin/bash

set -e

PORT=$1

if [ -z "$PORT" ]; then
  echo "Usage: ./setup_code_server.sh <port>"
  exit 1
fi

if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "Port must be a number"
  exit 1
fi

if [ "$PORT" -lt 1024 ] || [ "$PORT" -gt 65535 ]; then
  echo "Port must be between 1024 and 65535"
  exit 1
fi

USER_NAME=$(whoami)
HOME_DIR=$(eval echo ~$USER_NAME)
CONFIG_DIR="$HOME_DIR/.config/code-server"
PASSWORD=$(openssl rand -base64 18 | tr -dc 'A-Za-z0-9' | head -c 20)

echo "Installing code-server..."
curl -fsSL https://code-server.dev/install.sh | sh

echo "Creating config..."
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/config.yaml" <<EOF
bind-addr: 0.0.0.0:$PORT
auth: password
password: $PASSWORD
cert: false
EOF

echo "Enabling systemd service..."
sudo systemctl enable --now code-server@$USER_NAME

echo "----------------------------------------"
echo "Code-server installed successfully"
echo "User: $USER_NAME"
echo "Port: $PORT"
echo "Password: $PASSWORD"
echo "----------------------------------------"