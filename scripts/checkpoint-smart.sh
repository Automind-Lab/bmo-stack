#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_CHECKPOINT_SCRIPT="$SCRIPT_DIR/checkpoint.sh"

if [ ! -x "$BASE_CHECKPOINT_SCRIPT" ]; then
  echo "Error: checkpoint.sh not found or not executable at $BASE_CHECKPOINT_SCRIPT"
  exit 1
fi

REPO="${CHECKPOINT_REPO:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
BRANCH="${CHECKPOINT_BRANCH:-$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)}"
TIMESTAMP="${CHECKPOINT_TIMESTAMP:-$(date -u +"%Y-%m-%d %H:%M UTC")}" 
FILES_TOUCHED="${CHECKPOINT_FILES_TOUCHED:-}"
LAST_STEP="${CHECKPOINT_LAST_STEP:-}"
NEXT_STEP="${CHECKPOINT_NEXT_STEP:-}"
VERIFICATION_COMPLETE="${CHECKPOINT_VERIFICATION_COMPLETE:-false}"
MANUAL_STEPS="${CHECKPOINT_MANUAL_STEPS:-None recorded}"
SAFE_TO_RESUME="${CHECKPOINT_SAFE_TO_RESUME:-true}"

usage() {
  echo "Usage: checkpoint-smart.sh --last-step <text> --next-step <text> [options]"
  echo
  echo "Options:"
  echo "  --files-touched <text>"
  echo "  --verification-complete <true|false>"
  echo "  --manual-steps <text>"
  echo "  --safe-to-resume <true|false>"
  echo "  --repo <path>"
  echo "  --branch <name>"
  echo "  --timestamp <utc timestamp>"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --files-touched)
      FILES_TOUCHED="$2"
      shift 2
      ;;
    --last-step)
      LAST_STEP="$2"
      shift 2
      ;;
    --next-step)
      NEXT_STEP="$2"
      shift 2
      ;;
    --verification-complete)
      VERIFICATION_COMPLETE="$2"
      shift 2
      ;;
    --manual-steps)
      MANUAL_STEPS="$2"
      shift 2
      ;;
    --safe-to-resume)
      SAFE_TO_RESUME="$2"
      shift 2
      ;;
    --repo)
      REPO="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    --timestamp)
      TIMESTAMP="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [ -z "$LAST_STEP" ] || [ -z "$NEXT_STEP" ]; then
  echo "Error: --last-step and --next-step are required"
  usage
  exit 1
fi

if [ -z "$FILES_TOUCHED" ]; then
  FILES_TOUCHED="$(git -C "$REPO" status --short 2>/dev/null | awk '{print $2}' | paste -sd ', ' - || true)"
  FILES_TOUCHED="${FILES_TOUCHED:-none detected}"
fi

exec "$BASE_CHECKPOINT_SCRIPT" \
  --timestamp "$TIMESTAMP" \
  --repo "$REPO" \
  --branch "$BRANCH" \
  --files-touched "$FILES_TOUCHED" \
  --last-step "$LAST_STEP" \
  --next-step "$NEXT_STEP" \
  --verification-complete "$VERIFICATION_COMPLETE" \
  --manual-steps "$MANUAL_STEPS" \
  --safe-to-resume "$SAFE_TO_RESUME"
