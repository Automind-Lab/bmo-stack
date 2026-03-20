# Automation Workers

This branch is for expanding the GitHub and worker automation layer.

## Goal

Make the stack better at watching repos, proposing fixes, and handling repeatable maintenance work without pretending everything is fully autonomous.

## What belongs in this branch

- GitHub Actions workflows
- helper scripts for repo maintenance
- Cosmic Owl improvements
- Moe repair flows
- PR creation helpers
- maintenance reports
- worker automation docs

## Current automation shape

### Cosmic Owl
Currently acts as the GitHub watcher/caretaker.
Good jobs for Cosmic Owl:
- scheduled repo health checks
- stale issue and PR review
- workflow and dependency drift detection
- maintenance report generation
- opening an issue when attention is needed

### Moe
Currently defined as the GitHub repair/builder worker.
Good jobs for Moe:
- branch work
- repo repair
- patching
- draft PR preparation
- repetitive maintenance fixes

## Recommended next tasks

### 1. Add Moe draft PR flow
Teach Moe to:
- create a branch
- make a narrowly scoped change
- open a draft PR instead of pushing directly to main

### 2. Add safety guardrails
Document and enforce that automation workers:
- do not push directly to main by default
- prefer issues and draft PRs
- avoid destructive repo actions without explicit approval

### 3. Add maintenance labels and triage rules
Let workers apply or suggest labels for:
- stale
- docs
- maintenance
- needs-human-review

### 4. Add a sample report gallery
Show what a healthy report looks like and what an action-needed report looks like.

### 5. Add escalation rules
Document when Cosmic Owl should stop watching and hand off to:
- Moe for repair work
- NEPTR for verification
- a human for ambiguous or risky cases

## Real vs simulated

### Real
- GitHub Actions workflows
- helper scripts
- issue creation
- maintenance reports

### Simulated or policy-based
- named worker personalities that are not yet separate automated runtimes
- orchestration rules that still depend on documented process

## Definition of done for automation work

A change in this branch should make automation:
- safer
- more useful
- more reviewable
- less noisy
- less magical and more explicit
