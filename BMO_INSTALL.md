# BMO Stack Install

Fresh Ubuntu install:

```bash
export NVIDIA_API_KEY=nvapi-...
curl -fsSL https://raw.githubusercontent.com/Automind-Lab/bmo-stack/master/install-ubuntu.sh | bash
```

This installer:

- updates the host
- installs missing prerequisites
- installs or updates OpenClaw
- installs or updates NemoClaw and OpenShell
- configures `bmo-main` and `bmo-lab`
- makes Nemotron selectable in `/model`

After install, run:

```bash
nemoclaw onboard
```
