# openclaw-5-agent-template

AI-powered development team using [OpenClaw](https://openclaw.sh) multi-agent system. Five specialized AI agents (Owner, QA Lead, Frontend Dev, Backend Dev, Tester) collaborate to build a React TS + NestJS web application. You chat in Discord or the web UI, and agents implement features, write tests, review code, and ship PRs.

## Architecture

```
You (Discord / Web UI)
        |
   ┌────┴────────────────────────────────────┐
   │           Traefik (reverse proxy)        │
   │     auto-discovers all projects          │
   └────┬────────────┬──────────────────┬─────┘
        |            |                  |
   ┌────┴────┐  ┌────┴────┐      ┌─────┴─────┐
   │ OpenClaw│  │  code-  │      │    dev-    │
   │ gateway │  │  server │      │   server   │
   │         │  │ (IDE)   │      │ (build/test│
   │ 5 agents│  │         │      │  Node 22)  │
   └─────────┘  └─────────┘      └────────────┘

   Agents EDIT code        You BROWSE code    Agents RUN builds
   via OpenClaw tools      in browser IDE     via SSH
```

## Tech Stack

| Layer | Tech |
|-------|------|
| Frontend | React 18+, TypeScript strict, Vite, Vitest, Tailwind CSS |
| Backend | NestJS, TypeScript strict, PostgreSQL, Jest, Swagger |
| Shared | `packages/*` for shared types/utils (`@myorg/<name>`) |
| Monorepo | npm workspaces |
| CI | GitHub Actions |
| Agents | OpenClaw + Claude API (Opus 4.6 / Sonnet 4.5) |
| Infra | Docker Compose, Traefik, code-server |

## Agents

| Agent | Role | Model | What They Do |
|-------|------|-------|-------------|
| @owner | Commander | Opus 4.6 | Decomposes tasks, assigns work, merges PRs |
| @qa | Quality Gatekeeper | Sonnet 4.5 | Reviews PRs for code quality, security, types |
| @frontend | React Dev | Sonnet 4.5 | Builds React components, hooks, pages, tests |
| @backend | NestJS Dev | Sonnet 4.5 | Builds API modules, services, controllers, tests |
| @tester | QA Engineer | Sonnet 4.5 | Writes tests, verifies PRs, maintains CI |

## Project Structure

```
.
├── apps/
│   ├── web/                    # React TS + Vite frontend
│   └── api/                    # NestJS backend
├── packages/                   # Shared TS libraries (@myorg/<name>)
├── .openclaw/
│   ├── openclaw.json           # Agent config, channels, skills
│   ├── shared/                 # Shared agent docs (TEAM-RULEBOOK, TOOLS-COMMON)
│   ├── workspace-owner/        # Owner agent workspace
│   ├── workspace-qa-lead/      # QA agent workspace
│   ├── workspace-frontend/     # Frontend agent workspace
│   ├── workspace-backend/      # Backend agent workspace
│   └── workspace-tester/       # Tester agent workspace
├── build/
│   ├── Dockerfile              # Dev-server image (Ubuntu + Node 22 + git + code-server)
│   ├── start.sh                # Entrypoint (SSH, key gen, code-server)
│   ├── code-server-config.yaml
│   └── ssh-config              # SSH config for gateway → dev-server (StrictHostKeyChecking no)
├── .github/workflows/ci.yml    # CI pipeline (lint + test both apps)
├── docker-compose.yml          # Per-project: dev-server + openclaw-gateway
├── docker-compose-traefik.yml  # Central: Traefik reverse proxy (shared)
├── .env                        # Secrets + PROJECT_NAME (not committed)
├── .env.example                # Template for .env
└── Makefile                    # Convenience commands
```

## Quick Start

### Prerequisites

- Docker + Docker Compose v2
- GitHub CLI (`gh`)
- Anthropic API key
- Discord account (for bot creation)

### 1. Clone and configure

```bash
git clone https://github.com/<you>/openclaw-5-agent-template.git
cd openclaw-5-agent-template

cp .env.example .env
# Edit .env:
#   PROJECT_NAME=myproject
#   ANTHROPIC_API_KEY=sk-ant-...
#   GITHUB_TOKEN=ghp_...
#   DEV_USER_PASSWORD=<something-secure>
```

### 2. Create Discord bot

Create a Discord bot at https://discord.com/developers/applications:

1. New Application → Bot → Reset Token → copy token
2. Bot settings: enable **Message Content Intent**
3. OAuth2 → URL Generator → Select scopes: `bot`, `applications.commands`
4. Bot Permissions: Check required permissions (Send Messages, Read Message History, etc.)
5. Copy the generated URL and invite bot to your Discord server

Configure the bot token in `.openclaw/openclaw.json`:
```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "YOUR_DISCORD_BOT_TOKEN",
      "guilds": {
        "YOUR_GUILD_ID": {
          "channels": ["CHANNEL_ID"]
        }
      }
    }
  }
}
```

See [docs/DISCORD-SETUP.md](docs/DISCORD-SETUP.md) for detailed instructions on getting Guild IDs and Channel IDs.

### 3. Start Traefik (once, shared across projects)

```bash
make traefik-start
```

### 4. Build and start

```bash
make build
make start
```

### 5. Install Linux-native dependencies (first time)

The host machine (macOS/Windows) installs native binaries (esbuild, swc) that won't work inside the Linux dev-server container. You must run `npm install` inside the container:

```bash
make dev-install
```

This runs `npm install` inside the dev-server, compiling native modules for Linux. **Run this once after first start, and again whenever you add/change dependencies.**

### 6. Install OpenClaw skills

```bash
make install-skills
```

### 7. Verify

```bash
make status
```

| Service | URL |
|---------|-----|
| Code Server (IDE) | `http://${PROJECT_NAME}.code.localhost` |
| OpenClaw Web UI | `http://${PROJECT_NAME}.openclaw.localhost` |
| Traefik Dashboard | `http://traefik.localhost` |
| SSH | `ssh dev@127.0.0.1 -p 2222` |

### 8. Verify SSH from gateway to dev-server

Agents need SSH access from the gateway container to the dev-server for running builds/tests. Verify it works:

```bash
# Check that gateway can SSH into dev-server
docker exec ${PROJECT_NAME:-project}-gateway ssh dev@dev-server "echo OK"
```

If SSH client is not installed in the OpenClaw image, you may need to install it:

```bash
docker exec ${PROJECT_NAME:-project}-gateway apk add --no-cache openssh-client 2>/dev/null || \
docker exec ${PROJECT_NAME:-project}-gateway apt-get install -y openssh-client 2>/dev/null
```

### 9. Start chatting

Message in your Discord server:

> "I want a user authentication system with login and register"

The @owner agent will decompose the task, assign to @frontend and @backend, and the team will implement it.

## How It Works

### Feature Delivery Flow

```
You: "I want user authentication"
  |
  v
@owner decomposes into GitHub Issues:
  - Issue #1: feat(api): auth endpoints        → assigns @backend
  - Issue #2: feat(web): login page             → assigns @frontend
  |
  v
@backend implements:
  - Creates feature branch feat/be-auth
  - Builds NestJS auth module (entity, service, controller, DTOs)
  - Writes Jest tests
  - Runs: lint → test → build (via SSH to dev-server)
  - Runs quality gates (type check, OWASP scan, secrets scan)
  - Creates PR
  |
@frontend implements:
  - Creates feature branch feat/fe-login
  - Builds React components (LoginForm, useAuth hook)
  - Writes Vitest tests
  - Runs: lint → test → build (via SSH to dev-server)
  - Runs quality gates (type check, a11y, anti-patterns)
  - Creates PR
  |
  v
@tester verifies:
  - Runs full test suites
  - Writes new tests for added functionality
  - Reports results
  |
  v
@qa reviews:
  - Code quality, security, TypeScript strict, test coverage
  - Approves or requests changes
  |
  v
@owner merges after both approve
  |
  v
You: "Authentication is shipped."
```

### How Agents Implement Code

Agents use **two different mechanisms** depending on the action:

**1. OpenClaw built-in file tools** (no SSH needed) — for editing code:
- `Read` — read any file in `/home/node/projects/`
- `Write` — create or overwrite a file
- `Edit` — find-and-replace within a file
- `Exec` — run shell commands inside the gateway container

These tools work directly on the project files mounted into the openclaw-gateway container. Agents do NOT need to SSH into dev-server to read or edit code.

**2. SSH to dev-server** — for running builds, tests, and linting:

```bash
ssh dev@dev-server "cd ~/projects/apps/web && npm test -- --run"
ssh dev@dev-server "cd ~/projects/apps/api && npm run build"
```

The dev-server has Node.js 22, npm, and Linux-native binaries — it's the execution environment.

| Action | How | Where |
|--------|-----|-------|
| Read/write/edit files | OpenClaw file tools | openclaw-gateway container (full access) |
| `npm run lint` | `ssh dev@dev-server "..."` | dev-server container (apps/ only) |
| `npm test` | `ssh dev@dev-server "..."` | dev-server container (apps/ only) |
| `npm run build` | `ssh dev@dev-server "..."` | dev-server container (apps/ only) |
| `git commit`, `git push` | OpenClaw exec | openclaw-gateway container (full access) |
| `gh pr create` | OpenClaw exec | openclaw-gateway container (full access) |

**Volume optimization:** The dev-server only mounts `apps/`, `packages/`, and essential config files (not the full project). This improves security and performance. The gateway keeps full project access for editing all files and git operations.

Agents don't need a running dev server (`npm run dev`). They verify correctness via builds and tests only.

### Container Connectivity

```
openclaw-gateway ──SSH──> dev-server
       │                      │
       │  Gateway: Full       │  Dev-server: apps/ only
       │  project mount       │  (optimized)
       └──────────────────────┘
```

- **Network**: Both containers share the `internal` network. The gateway resolves `dev-server` via Docker DNS.
- **Volume mounts**:
  - **Gateway**: Full project mount (needs access to all files for editing, git operations)
  - **Dev-server**: Optimized mount - only `apps/`, `packages/`, `package.json`, `package-lock.json`, `node_modules/` (only needs code for builds/tests)
- **SSH keys**: Dev-server generates an ed25519 keypair at first boot. The key is shared via a volume mount (`data/dev/.openclaw-ssh/`) so the gateway can authenticate.
- **SSH config**: `build/ssh-config` is mounted into the gateway at `/home/node/.ssh/config` with `StrictHostKeyChecking no` to prevent interactive host verification prompts (agents can't answer "yes/no").
- **Git identity**: The gateway has `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_NAME`, `GIT_COMMITTER_EMAIL` set via environment variables so `git commit` works without `git config`.

### Previewing Results

After agents finish, you can preview:

```bash
# SSH into dev-server
make ssh

# Start frontend
cd ~/projects/apps/web && npm run dev
# Open http://localhost:5173

# Start backend
cd ~/projects/apps/api && npm run start:dev
# Open http://localhost:3000/api/docs (Swagger)
```

Or browse code via code-server: `http://${PROJECT_NAME}.code.localhost`

## Multi-Project Setup

Each project runs its own OpenClaw instance. Traefik routes by subdomain.

```bash
# Project 1 (.env: PROJECT_NAME=myproject, SSH_PORT=2222)
cd ~/projects/myproject && make start

# Project 2 (.env: PROJECT_NAME=saas-app, SSH_PORT=2223)
cd ~/projects/saas-app && make start

# Project 3 (.env: PROJECT_NAME=mobile-api, SSH_PORT=2224)
cd ~/projects/mobile-api && make start
```

| Project | Code Server | OpenClaw | SSH |
|---------|------------|----------|-----|
| myproject | `myproject.code.localhost` | `myproject.openclaw.localhost` | port 2222 |
| saas-app | `saas-app.code.localhost` | `saas-app.openclaw.localhost` | port 2223 |
| mobile-api | `mobile-api.code.localhost` | `mobile-api.openclaw.localhost` | port 2224 |

## Makefile Commands

```bash
# Core
make help                # Show all commands
make start               # Start this project (auto-creates traefik_net)
make stop                # Stop this project
make restart             # Restart this project
make build               # Rebuild dev-server image (no cache)
make logs                # Follow logs
make status              # Show URLs and container status

# Dev Server
make ssh                 # SSH into dev-server
make dev-install         # Run npm install inside dev-server (first time + deps change)
make update-password     # Change dev-server / code-server password
make fix-data-permission # Fix ./data ownership to UID 1000

# Traefik
make traefik-start       # Start Traefik (once, shared across projects)
make traefik-stop        # Stop Traefik
make traefik-logs        # Follow Traefik logs

# OpenClaw
make install-skills      # Install all 33 OpenClaw skills
make openclaw-setup      # First-time OpenClaw onboarding
make openclaw-cmd cmd="" # Run any OpenClaw CLI command
make openclaw-devices-list    # List connected devices
make openclaw-devices-approve # Approve a device
```

## OpenClaw Skills (33 installed)

### Shared (all agents)
`github-pro`, `self-improving-agent`

### Frontend (16 skills)
| Category | Skills |
|----------|--------|
| TypeScript | `typescript-lsp`, `anti-pattern-czar`, `neo-es6-refactor` |
| React | `react-perf`, `sovereign-test-generator`, `critical-code-reviewer` |
| Styling | `lb-tailwindcss-skill`, `shadcn-theme-default`, `anti-slop-design`, `kj-ui-ux-pro-max` |
| Validation | `lb-zod-skill` |
| Accessibility | `axe-devtools`, `sovereign-accessibility-auditor` |
| Animation | `lb-motion-skill` |
| API | `neo-api-to-ts-interface` |
| Deploy | `deploy-pilot` |

### Backend (15 skills)
| Category | Skills |
|----------|--------|
| NestJS | `agent-nestjs-skills`, `backend-patterns`, `api-dev` |
| Database | `postgres-perf`, `database-designer` |
| Security | `secure-auth-patterns`, `api-security`, `code-security-audit`, `ggshield-scanner` |
| Testing | `test-sentinel`, `bug-audit`, `debug-methodology` |
| DevOps | `agentic-devops`, `secrets-management` |

## Agent Knowledge

Each agent has specialized knowledge files:

| File | Auto-loaded | Purpose |
|------|-------------|---------|
| `SOUL.md` | Yes | Identity, rules, patterns, best practices |
| `IDENTITY.md` | Yes | Short identity description |
| `AGENTS.md` | Yes | Operating instructions, workflows, templates |
| `USER.md` | Yes | Info about the human |
| `MEMORY.md` | Yes | Persistent memory across sessions |
| `TOOLS.md` | No (agent reads) | Available tools, commands, skills |
| `.learnings/` | No (agent reads) | Errors, learnings, feature requests |

The backend agent has **40 NestJS best practices** embedded in its SOUL.md covering: architecture, dependency injection, error handling, security, performance, testing, database/ORM, API design, microservices, and DevOps.

## Environment Variables

See `.env.example` for the full template:

| Variable | Required | Description |
|----------|----------|-------------|
| `PROJECT_NAME` | Yes | Unique name for Traefik routing |
| `ANTHROPIC_API_KEY` | Yes | Claude API key |
| `GITHUB_TOKEN` | Yes | GitHub personal access token |
| `DEV_USER_PASSWORD` | Yes | Password for dev-server + code-server |
| `GIT_USER_NAME` | No | Git author name (default: openclaw-5-agent-template) |
| `GIT_USER_EMAIL` | No | Git author email (default: bot@myorg.dev) |
| `SSH_PORT` | No | SSH port (default: 2222) |
| `DEV_USER` | No | Dev-server username (default: dev) |

## Troubleshooting

### `npm test` or `npm run build` fails with binary errors

Native binaries (esbuild, swc, etc.) compiled on macOS won't work inside the Linux dev-server container. Fix:

```bash
make dev-install
```

This runs `npm install` inside the container to get Linux-native binaries.

### `traefik_net` network not found

If `make start` fails with a network error, Traefik hasn't been started yet. The Makefile auto-creates the network, but if it doesn't:

```bash
docker network create traefik_net
make start
```

### SSH from gateway to dev-server fails

Check:

1. **Key exists**: `ls data/dev/.openclaw-ssh/id_ed25519` — generated on first boot of dev-server
2. **SSH config mounted**: `docker exec ${PROJECT_NAME}-gateway cat /home/node/.ssh/config`
3. **SSH client installed**: `docker exec ${PROJECT_NAME}-gateway which ssh`
4. **Network connectivity**: `docker exec ${PROJECT_NAME}-gateway ping -c1 dev-server`

### `git commit` fails with "please tell me who you are"

The gateway container needs git identity. This is set via environment variables in `docker-compose.yml`:

```yaml
- GIT_AUTHOR_NAME=${GIT_USER_NAME:-openclaw-5-agent-template}
- GIT_AUTHOR_EMAIL=${GIT_USER_EMAIL:-bot@myorg.dev}
- GIT_COMMITTER_NAME=${GIT_USER_NAME:-openclaw-5-agent-template}
- GIT_COMMITTER_EMAIL=${GIT_USER_EMAIL:-bot@myorg.dev}
```

If it still fails, verify with: `docker exec ${PROJECT_NAME}-gateway env | grep GIT`

### Permission denied on `./data/`

The dev-server runs as UID 1000. Fix ownership:

```bash
make fix-data-permission
```

### Host verification prompt blocks SSH

Agents can't answer interactive "Are you sure you want to continue connecting?" prompts. This is solved by `build/ssh-config` which sets `StrictHostKeyChecking no`. Verify it's mounted:

```bash
docker exec ${PROJECT_NAME}-gateway cat /home/node/.ssh/config
```

## License

Private project.
