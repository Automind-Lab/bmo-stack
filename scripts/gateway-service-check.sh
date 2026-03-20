#!/usr/bin/env bash

set -euo pipefail

print_status() {
  echo "$1"
}

if ! command -v openclaw >/dev/null 2>&1; then
  print_status "openclaw binary not found"
  exit 0
fi

print_status "Checking OpenClaw gateway status..."
openclaw gateway status || true

if command -v systemctl >/dev/null 2>&1; then
  print_status ""
  print_status "Checking systemd user service state..."
  if systemctl --user is-active openclaw-gateway.service >/dev/null 2>&1; then
    print_status "openclaw-gateway.service is active"
  else
    print_status "openclaw-gateway.service is not active or not installed"
  fi
fi

print_status ""
print_status "Interpretation:"
print_status "- If the gateway dies when the terminal closes, it is probably running in the foreground instead of as a managed service."
print_status "- For daily use, prefer: openclaw gateway install, openclaw gateway start, openclaw gateway status."
