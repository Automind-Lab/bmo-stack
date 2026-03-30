#!/usr/bin/env bash
set -euo pipefail

STACK_NAME="BMO Stack"
REPO_SLUG="Automind-Lab/bmo-stack"
REPO_BRANCH="master"
REPO_DIR="${HOME}/bmo-stack"

OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
OPENCLAW_CONFIG="${OPENCLAW_CONFIG:-$OPENCLAW_HOME/openclaw.json}"
OPENCLAW_ENV_FILE="$OPENCLAW_HOME/.env"

HOST_AGENT_ID="${BMO_HOST_AGENT_ID:-bmo-main}"
WORKER_AGENT_ID="${BMO_WORKER_AGENT_ID:-bmo-lab}"
HOST_WORKSPACE="${BMO_HOST_WORKSPACE:-$OPENCLAW_HOME/workspace-bmo-main}"
WORKER_WORKSPACE="${BMO_WORKER_WORKSPACE:-$OPENCLAW_HOME/workspace-bmo-lab}"

MAIN_MODEL_REF="${BMO_MAIN_MODEL_REF:-nvidia/nvidia/nemotron-3-super-120b-a12b}"
ALT_MODEL_REF="${BMO_ALT_MODEL_REF:-nvidia/nvidia/llama-3.1-nemotron-70b-instruct}"

if [[ -z "${NVIDIA_API_KEY:-}" ]]; then
  echo "Error: NVIDIA_API_KEY is required."
  echo "Example:"
  echo "  export NVIDIA_API_KEY=nvapi-..."
  echo "  curl -fsSL https://raw.githubusercontent.com/${REPO_SLUG}/${REPO_BRANCH}/install.sh | bash"
  exit 1
fi

SUDO=""
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  SUDO="sudo"
fi

note() {
  printf '\n==> %s\n' "$1"
}

write_env_key() {
  mkdir -p "$OPENCLAW_HOME"
  touch "$OPENCLAW_ENV_FILE"
  tmp_file="$(mktemp)"
  grep -v '^NVIDIA_API_KEY=' "$OPENCLAW_ENV_FILE" > "$tmp_file" || true
  printf 'NVIDIA_API_KEY=%s\n' "$NVIDIA_API_KEY" >> "$tmp_file"
  mv "$tmp_file" "$OPENCLAW_ENV_FILE"
  chmod 600 "$OPENCLAW_ENV_FILE"
}

maybe_copy_repo_env() {
  if [[ -f "$REPO_DIR/.env.example" && ! -f "$REPO_DIR/.env" ]]; then
    cp "$REPO_DIR/.env.example" "$REPO_DIR/.env"
  fi

  if [[ -f "$REPO_DIR/.env" ]]; then
    tmp_file="$(mktemp)"
    grep -v '^NVIDIA_API_KEY=' "$REPO_DIR/.env" > "$tmp_file" || true
    printf 'NVIDIA_API_KEY=%s\n' "$NVIDIA_API_KEY" >> "$tmp_file"
    mv "$tmp_file" "$REPO_DIR/.env"
  fi
}

install_packages() {
  note "Installing host packages"
  $SUDO apt-get update
  $SUDO apt-get install -y curl git rsync ca-certificates docker.io docker-compose-plugin
  $SUDO systemctl enable --now docker
  if [[ -n "$SUDO" ]]; then
    $SUDO usermod -aG docker "$USER" || true
  fi
}

install_openclaw() {
  if command -v openclaw >/dev/null 2>&1; then
    note "OpenClaw already installed"
    return
  fi

  note "Installing OpenClaw"
  curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
}

refresh_path() {
  if command -v npm >/dev/null 2>&1; then
    export PATH="$(npm prefix -g)/bin:$PATH"
  fi
  export PATH="$HOME/.local/bin:$PATH"
}

install_nemoclaw() {
  if command -v nemoclaw >/dev/null 2>&1; then
    note "NemoClaw already installed"
    return
  fi

  note "Installing NemoClaw / OpenShell"
  curl -fsSL https://nvidia.com/nemoclaw.sh | bash || true
  refresh_path
}

bootstrap_openclaw_if_needed() {
  if [[ -f "$OPENCLAW_CONFIG" ]]; then
    note "OpenClaw config already present"
    return
  fi

  note "Running non-interactive OpenClaw onboarding"
  openclaw onboard --non-interactive \
    --mode local \
    --auth-choice skip \
    --accept-risk \
    --gateway-port 18789 \
    --gateway-bind loopback \
    --install-daemon \
    --daemon-runtime node \
    --skip-skills
}

sync_repo() {
  note "Cloning ${STACK_NAME}"
  rm -rf "$REPO_DIR"
  git clone --branch "$REPO_BRANCH" "https://github.com/${REPO_SLUG}.git" "$REPO_DIR"
}

apply_repo_topology() {
  note "Applying BMO host/lab topology"
  cd "$REPO_DIR"
  maybe_copy_repo_env
  mkdir -p "$HOST_WORKSPACE" "$WORKER_WORKSPACE"
}

patch_openclaw_config() {
  note "Writing NVIDIA provider and selectable model catalog"

  node - "$OPENCLAW_CONFIG" "$HOST_WORKSPACE" "$WORKER_WORKSPACE" "$HOST_AGENT_ID" "$WORKER_AGENT_ID" "$MAIN_MODEL_REF" "$ALT_MODEL_REF" <<'NODE'
const fs = require("node:fs");
const path = require("node:path");

const [
  configPath,
  hostWorkspace,
  workerWorkspace,
  hostAgentId,
  workerAgentId,
  mainModelRef,
  altModelRef,
] = process.argv.slice(2);

let cfg = {};
if (fs.existsSync(configPath)) {
  const raw = fs.readFileSync(configPath, "utf8").trim();
  cfg = raw ? JSON.parse(raw) : {};
}

cfg.models ??= {};
cfg.models.providers ??= {};
cfg.models.providers.nvidia = {
  ...(cfg.models.providers.nvidia || {}),
  baseUrl: "https://integrate.api.nvidia.com/v1",
  api: "openai-completions",
};

cfg.agents ??= {};
cfg.agents.defaults ??= {};
cfg.agents.defaults.workspace = hostWorkspace;
cfg.agents.defaults.sandbox = { mode: "off" };
cfg.agents.defaults.model = { ...(cfg.agents.defaults.model || {}), primary: mainModelRef };
cfg.agents.defaults.models = {
  ...(cfg.agents.defaults.models || {}),
  [mainModelRef]: {
    alias: "Nemotron3 Super 120B",
  },
  [altModelRef]: {
    alias: "Nemotron 70B",
  },
};

cfg.agents.list = Array.isArray(cfg.agents.list) ? cfg.agents.list : [];

const upsert = (agent) => {
  const index = cfg.agents.list.findIndex((item) => item.id === agent.id);
  if (index >= 0) cfg.agents.list[index] = { ...cfg.agents.list[index], ...agent };
  else cfg.agents.list.push(agent);
};

upsert({
  id: hostAgentId,
  default: true,
  workspace: hostWorkspace,
  sandbox: { mode: "off" },
  model: { primary: mainModelRef },
});

upsert({
  id: workerAgentId,
  default: false,
  workspace: workerWorkspace,
  sandbox: {
    mode: "all",
    scope: "agent",
    docker: { network: "bridge" },
  },
  model: { primary: mainModelRef },
});

for (const agent of cfg.agents.list) {
  if (agent.id !== hostAgentId && agent.default === true) {
    agent.default = false;
  }
}

fs.mkdirSync(path.dirname(configPath), { recursive: true });
fs.writeFileSync(configPath, JSON.stringify(cfg, null, 2) + "\n");
NODE
}

restart_gateway() {
  note "Validating and restarting the gateway"
  openclaw config validate
  openclaw gateway restart || openclaw daemon restart || true
}

print_summary() {
  cat <<EOF

${STACK_NAME} is ready.

Repo:        $REPO_DIR
Host agent:  $HOST_AGENT_ID
Worker agent:$WORKER_AGENT_ID
Main model:  $MAIN_MODEL_REF

Useful checks:
  openclaw models status
  openclaw models list
  make doctor
  make worker-status

In chat:
  /model

EOF
}

install_packages
install_openclaw
refresh_path
install_nemoclaw
refresh_path
write_env_key
bootstrap_openclaw_if_needed
sync_repo
apply_repo_topology
patch_openclaw_config
restart_gateway
print_summary
