# Troubleshooting

This page is for the moments when something goes wrong.
Do not panic.
Most setup problems are fixable.

## Problem: `git clone` does not work

### What it usually means
Git is not installed, or your internet connection failed.

### What to do
- Make sure Git is installed
- Try the command again
- Make sure you copied the repo address correctly

## Problem: `.env` does not exist

### What it usually means
You forgot to create it from `.env.example`.

### What to do
Run:

```bash
cp .env.example .env
```

## Problem: `make doctor` reports missing tools

### What it usually means
One or more prerequisites are not installed.

### What to do
Install the missing tool first, then run `make doctor` again.

## Problem: Docker will not start

### What it usually means
Docker is not installed, not running, or not fully started yet.

### What to do
- Open Docker Desktop if you are using it
- Wait for Docker to fully start
- Then run your command again

## Problem: OpenClaw is not running

### What it usually means
The assistant software is not started on your computer.

### What to do
Run:

```bash
make openclaw-start
make openclaw-status
```

## Problem: The worker sandbox will not connect

### What it usually means
The sandbox may not exist yet, or it may not have the right config.

### What to do
Run these in order:

```bash
make worker-create
make worker-upload-config
make worker-connect
```

## Problem: After a restart, the assistant forgot what it was doing

### What it usually means
The session restarted and the assistant needs to reload context.

### What to do
Run:

```bash
make recover-session
```

This checks task state, work in progress, and repo status.

## Problem: GitHub worker did not fix anything

### What it usually means
The GitHub watcher is meant to observe and open issues or reports first.
It does not silently rewrite your project by default.

### What to do
- Read the report or issue it created
- Decide whether you want to apply the suggested fix
- Use a repair worker or manual review for deeper changes

## Problem: I do not understand the words in this project

### What to do
Read:
- `docs/GLOSSARY.md`
- `docs/WHAT_EACH_PART_DOES.md`

## Most important advice

If you are stuck:
1. Run `make doctor`
2. Run `make recover-session`
3. Read the error message slowly
4. Check `README_BEGINNER.md` and `docs/STEP_BY_STEP_SETUP.md`
5. Do one fix at a time
