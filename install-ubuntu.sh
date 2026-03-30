#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${NVIDIA_API_KEY:-}" ]]; then
  echo "NVIDIA_API_KEY is required"
  exit 1
fi

curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
export PATH="$(npm prefix -g)/bin:$PATH"

TMP_FILE="$(mktemp /tmp/bmo-install-ubuntu.XXXXXX.mjs)"
curl -fsSL https://raw.githubusercontent.com/Automind-Lab/bmo-stack/master/install-ubuntu.mjs -o "$TMP_FILE"
node "$TMP_FILE"
rm -f "$TMP_FILE"
