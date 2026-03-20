# Community Template

This branch is for making BMO Stack easier for other people to copy, understand, and adapt.

## Goal

Turn the repo into a cleaner template for other builders, not just Prismtek's own setup.

## What belongs in this branch

- removing or minimizing Prismtek-specific assumptions
- clearer examples and placeholders
- starter context files that are safe for other people to copy
- setup defaults that do not assume prior history
- better explanations for what users should customize first

## What should stay personal

The repo can still demonstrate the original architecture, but it should avoid forcing new users to inherit very specific personal context.

## Recommended next tasks

### 1. Add starter templates
Create copyable starter files such as:
- `context/BOOTSTRAP.example.md`
- `context/SESSION_STATE.example.md`
- `context/TASK_STATE.example.md`
- `context/WORK_IN_PROGRESS.example.md`

### 2. Add a "customize this first" guide
Explain the first things a new user should rename or edit:
- assistant name
- worker name
- API keys
- host context path assumptions
- GitHub workflow thresholds

### 3. Reduce personal references in front-door docs
Make sure the repo welcomes anyone using it, not only the original setup.

### 4. Add a template-mode quickstart
Show the shortest path for a new person to create their own version of the stack.

### 5. Keep honesty high
Clearly label:
- what is real
- what is simulated/policy-based
- what still requires manual setup

## Definition of done for template work

A change in this branch should make the repo:
- easier to fork
- easier to rename
- easier to understand without prior context
- less tied to one person's existing files and routines
