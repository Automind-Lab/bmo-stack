# What Each Part Does

This page explains the project in plain English.

## The big picture

This project helps you run an AI assistant system.
Some parts talk to you.
Some parts do background work.
Some parts remember important information.

## BMO

**BMO** is the helper that talks to you.
Think of BMO as the friendly front desk.
When you ask a question, BMO is the one that answers.

## bmo-tron

**bmo-tron** is the worker sandbox.
A **sandbox** is a safer, more isolated place where riskier jobs can happen.
You can think of it like a workshop room instead of the front desk.

## OpenClaw

**OpenClaw** is the software that runs the assistant on your computer.
It helps handle conversations and tools.

## NemoClaw and OpenShell

**NemoClaw** and **OpenShell** help manage the worker sandbox.
They are part of the system that creates and uses `bmo-tron`.

## Host vs worker

These words matter:

- **Host** = your main computer environment
- **Worker** = the isolated helper environment used for certain jobs

In this project:
- the **host** is where the main assistant and stable context live
- the **worker** is where isolated or riskier tasks happen

## Context files

**Context files** are notes the assistant reads so it can remember important information after restarts.

Examples:
- `BOOTSTRAP.md`
- `SESSION_STATE.md`
- `RUNBOOK.md`
- `TASK_STATE.md`
- `WORK_IN_PROGRESS.md`

These help the assistant recover after crashes or session resets.

## Council roles

The project also uses named roles inspired by Adventure Time.
These roles help organize responsibilities.

Examples:
- **Prismo** = orchestration
- **NEPTR** = verification
- **Cosmic Owl** = GitHub watcher
- **Moe** = repair worker

Some of these are real automated parts.
Some are documented roles that guide behavior.

## GitHub

GitHub is the website where the project files live online.
It also can run automation, such as workflows that watch your repo.

## Docker

Docker is a tool that can run helper services in a container.
A **container** is like a packaged mini-environment.
In this project, Docker is mainly for optional helper services.

## What is real vs simulated

### Real
- OpenClaw on the host
- the worker sandbox
- context files
- GitHub workflows such as the caretaker

### Simulated or policy-based
- some named council roles that are documented as responsibilities, but are not all separate automated agents

## The most important idea

The assistant should not keep all important knowledge only in live memory.
Important information should live in files on the host so it can be recovered after restarts.
