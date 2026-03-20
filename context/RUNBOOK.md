# RUNBOOK

Source of truth:
- openshell sandbox list = live truth
- nemoclaw list = cached state, may lie
- ~/bmo-context/* = canonical project context

Useful checks:
- openclaw config validate
- openclaw channels status --probe
- systemctl --user status openclaw-gateway.service --no-pager
- openshell status
- openshell sandbox list
- docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

Worker:
- sandbox name: bmo-tron
- use it for isolated commands, repo inspection, and risky work

Recovery rules:
- If Telegram breaks, keep it on host.
- If nemoclaw list and openshell sandbox list disagree, trust openshell.
- If important sandbox files are missing, recover from ~/bmo-context.

## Worker Responsibility Split

BMO is focused on conversation, context, and final replies.  
Prismo routes and orchestrates.  
Specialists do narrow jobs.  
NEPTR verifies before claiming done.

See `context/WORKER_NAMING_REGISTRY.md` for the detailed responsibility map.
