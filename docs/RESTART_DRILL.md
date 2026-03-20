# Restart Recovery Drill

This guide helps you test whether restart recovery still works.

## Goal

Prove that the system can recover after an interruption by using host context files, task state files, and repo state checks.

## Before you start

Make sure these exist:
- `~/bmo-context/BOOTSTRAP.md`
- `~/bmo-context/SESSION_STATE.md`
- `~/bmo-context/SYSTEMMAP.md`
- `~/bmo-context/RUNBOOK.md`
- `~/bmo-context/BACKLOG.md`
- `~/bmo-context/TASK_STATE.md`
- `~/bmo-context/WORK_IN_PROGRESS.md`

## Step 1: Record a checkpoint

Run a checkpoint before the test.
Example:

```bash
make checkpoint ARGS="--repo $HOME/.openclaw/workspace/bmo-stack --branch master --files-touched docs/RESTART_DRILL.md --last-step 'Prepared restart drill' --next-step 'Simulate interruption and recover' --verification-complete false --manual-steps 'Complete restart drill' --safe-to-resume true"
```

## Step 2: Simulate interruption

Create a harmless temporary file in the repo:

```bash
touch $HOME/.openclaw/workspace/bmo-stack/INTERRUPTED_WORK.tmp
```

This stands in for interrupted work.

## Step 3: Run session recovery

Run:

```bash
make recover-session
```

Then run:

```bash
make audit-runtime
```

## Step 4: Check what was recovered

You want to confirm that the system can still identify:
- the host context files
- the task state files
- the current repo and branch
- whether interrupted work exists
- whether it is safe to resume

## Step 5: Clean up

Remove the temporary file when you are done:

```bash
rm -f $HOME/.openclaw/workspace/bmo-stack/INTERRUPTED_WORK.tmp
```

Then write a final checkpoint marking the drill complete.

## What success looks like

- recovery scripts run without confusion
- the repo state is visible
- task state is visible
- the system can tell whether work is safe to resume
- the temporary interruption does not cause panic or data loss

## Why this matters

A recovery system is only real if you test it.
This drill turns restart recovery from a nice idea into something you can prove works.
