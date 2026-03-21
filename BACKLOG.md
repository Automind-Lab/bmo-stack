# BACKLOG

Critical:
1. Keep ~/bmo-context as the canonical truth source. [DONE]
2. Make the host bot read context files before answering setup questions. [DONE]
3. Stop trusting stale NemoClaw registry state over openshell sandbox list. [DONE]
4. Re-seed worker bootstrap when a new sandbox is created. [DONE]
5. Keep host vs worker responsibilities explicit. [DONE]
6. Implement restart recovery protocol: at session start, read host context first, check TASK_STATE.md and WORK_IN_PROGRESS.md, inspect git status before asking user to restate anything. [DONE]

Important:
6. Add a one-command worker status check. [DONE]
7. Add a one-command context reseed. [DONE]
8. Clean up naming consistency. [DONE]
9. Turn planning docs into implementation-ready tasks. [DONE]
10. Reduce reply fragmentation. [DONE]

Nice-to-have:
11. Easier worker auth for openclaw tui. [DONE]
12. Add a project-state snapshot generator. [DONE]
13. Preserve important docs in a real repo later. [DONE - using bmo-context git repo]