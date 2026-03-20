#!/bin/bash
# Bootstrap script for macOS

set -euo pipefail

echo "=== BMO Stack Bootstrap for macOS ==="

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker Desktop for Mac."
    exit 1
fi

# Check for Docker Compose (v2)
if ! docker compose version &> /dev/null; then
    echo "Error: Docker Compose v2 is not available. Please ensure Docker Desktop is up to date."
    exit 1
fi

# Check for OpenClaw (host)
if [ ! -d "$HOME/.openclaw" ]; then
    echo "Warning: OpenClaw directory not found at $HOME/.openclaw"
    echo "Please install OpenClaw on your host machine first."
    echo "See: https://docs.openclaw.ai"
else
    echo "OpenClaw directory found at $HOME/.openclaw"
fi

# Check for context files
if [ ! -f "./context/BOOTSTRAP.md" ]; then
    echo "Error: Context files are missing. Please ensure you are in the bmo-stack directory."
    exit 1
fi

# Copy .env.example to .env if it doesn't exist
if [ ! -f ./.env ]; then
    if [ -f ./.env.example ]; then
        cp ./.env.example ./.env
        echo "Created .env from .env.example. Please edit it to add your API keys."
    else
        echo "Error: .env.example not found."
        exit 1
    fi
else
    echo ".env already exists. Skipping copy."
fi

echo ""
echo "=== Next Steps ==="
echo "1. Edit .env to add your NVIDIA API key (and any other required keys)."
echo "2. Ensure OpenClaw is running on your host machine."
echo "3. Use 'make up' to start any auxiliary services (currently just a placeholder)."
echo "4. The worker sandbox (bmo-tron) should be managed via OpenShell on the host."
echo "   You can create a worker sandbox with: openshell sandbox create --name bmo-tron"
echo "   Then upload your OpenClaw config: openshell sandbox upload bmo-tron ~/.openclaw/openclaw.json .openclaw/openclaw.json"
echo ""
echo "=== Done ==="