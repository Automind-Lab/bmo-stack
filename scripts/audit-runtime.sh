#!/usr/bin/env bash

set -euo pipefail

HOST_CONTEXT_DIR="${HOST_CONTEXT_DIR:-$HOME/bmo-context}"
WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/.openclaw/workspace}"
BMO_STACK_DIR="${BMO_STACK_DIR:-$WORKSPACE_DIR/bmo-stack}"

print_header() {
  echo
  echo "=== $1 ==="
}

check_file() {
  local path="$1"
  if [ -f "$path" ]; then
    echo "✓ $path exists"
  else
    echo "✗ $path missing"
  fi
}

check_dir() {
  local path="$1"
  if [ -d "$path" ]; then
    echo "✓ $path exists"
  else
    echo "✗ $path missing"
  fi
}

print_header "Host Context"
check_file "$HOST_CONTEXT_DIR/BOOTSTRAP.md"
check_file "$HOST_CONTEXT_DIR/SESSION_STATE.md"
check_file "$HOST_CONTEXT_DIR/SYSTEMMAP.md"
check_file "$HOST_CONTEXT_DIR/RUNBOOK.md"
check_file "$HOST_CONTEXT_DIR/BACKLOG.md"

print_header "Checkpoint Files"
check_file "$HOST_CONTEXT_DIR/TASK_STATE.md"
check_file "$HOST_CONTEXT_DIR/WORK_IN_PROGRESS.md"

print_header "Repo State"
if [ -d "$BMO_STACK_DIR/.git" ]; then
  echo "Repository: $BMO_STACK_DIR"
  branch_name="$(git -C "$BMO_STACK_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
  echo "Branch: $branch_name"
  echo "Status:"
  git -C "$BMO_STACK_DIR" status --short || true
  echo
  echo "Last 5 commits:"
  git -C "$BMO_STACK_DIR" log --oneline -5 || true
else
  echo "✗ bmo-stack git repository not found at $BMO_STACK_DIR"
fi

print_header "Safe To Resume"
if [ -f "$HOST_CONTEXT_DIR/TASK_STATE.md" ]; then
  last_safe="$(grep 'Safe to resume:' "$HOST_CONTEXT_DIR/TASK_STATE.md" | tail -1 | sed 's/.*Safe to resume: //' || true)"
  if [ -n "$last_safe" ]; then
    echo "Last checkpoint says safe to resume: $last_safe"
  else
    echo "Could not determine safe-to-resume state from TASK_STATE.md"
  fi
else
  echo "TASK_STATE.md missing; cannot determine safe-to-resume state"
fi

print_header "OpenClaw Gateway"
if command -v openclaw >/dev/null 2>&1; then
  openclaw gateway status || true
else
  echo "openclaw binary not found"
fi

if command -v systemctl >/dev/null 2>&1; then
  echo
  echo "systemd user service status (if available):"
  systemctl --user is-active openclaw-gateway.service 2>/dev/null || echo "openclaw-gateway.service is not active or not installed"
fi
