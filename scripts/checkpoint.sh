#!/usr/bin/env bash

# checkpoint.sh: Record a checkpoint in TASK_STATE.md and WORK_IN_PROGRESS.md for restart recovery

set -euo pipefail

HOST_CONTEXT_DIR="$HOME/bmo-context"
TASK_STATE_FILE="$HOST_CONTEXT_DIR/TASK_STATE.md"
WORK_IN_PROGRESS_FILE="$HOST_CONTEXT_DIR/WORK_IN_PROGRESS.md"

# Default values
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")
REPO=""
BRANCH=""
FILES_TOUCHED=""
LAST_STEP=""
NEXT_STEP=""
VERIFICATION_COMPLETE=""
MANUAL_STEPS=""
SAFE_TO_RESUME=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --timestamp)
            TIMESTAMP="$2"
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
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$REPO" || -z "$BRANCH" || -z "$FILES_TOUCHED" || -z "$LAST_STEP" || -z "$NEXT_STEP" || -z "$VERIFICATION_COMPLETE" || -z "$MANUAL_STEPS" || -z "$SAFE_TO_RESUME" ]]; then
    echo "Error: All arguments (--repo, --branch, --files-touched, --last-step, --next-step, --verification-complete, --manual-steps, --safe-to-resume) are required."
    exit 1
fi

# Function to append checkpoint to a file
append_checkpoint() {
    local file="$1"
    cat >> "$file" <<EOF

- $TIMESTAMP
  - Repo: $REPO
  - Branch: $BRANCH
  - Files touched: $FILES_TOUCHED
  - Last successful step: $LAST_STEP
  - Next intended step: $NEXT_STEP
  - Verification complete: $VERIFICATION_COMPLETE
  - Manual steps remaining: $MANUAL_STEPS
  - Safe to resume: $SAFE_TO_RESUME
EOF
}

# Append to both files
append_checkpoint "$TASK_STATE_FILE"
append_checkpoint "$WORK_IN_PROGRESS_FILE"

echo "Checkpoint recorded in $TASK_STATE_FILE and $WORK_IN_PROGRESS_FILE"