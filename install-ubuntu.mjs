import { execSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

if (!process.env.NVIDIA_API_KEY) {
  console.error('NVIDIA_API_KEY is required');
  process.exit(1);
}

const run = (cmd) => execSync(cmd, { stdio: 'inherit', shell: '/bin/bash' });
const home = os.homedir();
const openclawHome = process.env.OPENCLAW_HOME || path.join(home, '.openclaw');
const openclawConfig = process.env.OPENCLAW_CONFIG || path.join(openclawHome, 'openclaw.json');
const repoDir = path.join(home, 'bmo-stack');

run('sudo apt-get update -y');
run('sudo apt-get upgrade -y');
run('sudo apt-get install -y ca-certificates curl git jq make python3 python3-packaging rsync unzip xz-utils zip build-essential docker.io docker-compose-plugin');
run('sudo systemctl enable --now docker');
run('curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard');
run('export PATH="$(npm prefix -g)/bin:$PATH" && npm install -g nemoclaw@latest');

fs.mkdirSync(openclawHome, { recursive: true });
fs.writeFileSync(path.join(openclawHome, '.env'), `NVIDIA_API_KEY=${process.env.NVIDIA_API_KEY}\n`);

if (!fs.existsSync(repoDir)) {
  run(`git clone --branch master https://github.com/Automind-Lab/bmo-stack.git ${repoDir}`);
}

let cfg = {};
if (fs.existsSync(openclawConfig)) {
  const raw = fs.readFileSync(openclawConfig, 'utf8').trim();
  cfg = raw ? JSON.parse(raw) : {};
}

cfg.gateway ??= {};
cfg.gateway.mode = 'local';
cfg.gateway.port ??= 18789;
cfg.models ??= {};
cfg.models.providers ??= {};
cfg.models.providers.nvidia = { baseUrl: 'https://integrate.api.nvidia.com/v1', api: 'openai-completions' };
cfg.agents ??= {};
cfg.agents.defaults ??= {};
cfg.agents.defaults.workspace = path.join(home, '.openclaw', 'workspace-bmo-main');
cfg.agents.defaults.sandbox = { mode: 'off' };
cfg.agents.defaults.model = { primary: 'nvidia/nvidia/nemotron-3-super-120b-a12b' };
cfg.agents.defaults.models = {
  'nvidia/nvidia/nemotron-3-super-120b-a12b': { alias: 'Nemotron3 Super 120B' },
  'nvidia/nvidia/llama-3.1-nemotron-70b-instruct': { alias: 'Nemotron 70B' }
};
cfg.agents.list = [
  { id: 'bmo-main', default: true, workspace: path.join(home, '.openclaw', 'workspace-bmo-main'), sandbox: { mode: 'off' }, model: { primary: 'nvidia/nvidia/nemotron-3-super-120b-a12b' } },
  { id: 'bmo-lab', default: false, workspace: path.join(home, '.openclaw', 'workspace-bmo-lab'), sandbox: { mode: 'all', scope: 'agent', docker: { network: 'bridge' } }, model: { primary: 'nvidia/nvidia/nemotron-3-super-120b-a12b' } }
];
fs.writeFileSync(openclawConfig, JSON.stringify(cfg, null, 2) + '\n');

run('export PATH="$(npm prefix -g)/bin:$PATH" && openclaw gateway install --force');
run('export PATH="$(npm prefix -g)/bin:$PATH" && openclaw gateway restart || true');
run(`cd ${repoDir} && make doctor || true`);
run(`cd ${repoDir} && make worker-status || true`);
console.log('BMO hardened Ubuntu install complete');
console.log('Run nemoclaw onboard to create the sandbox');
