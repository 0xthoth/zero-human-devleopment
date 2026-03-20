# Setup Guide

Step-by-step from zero to agents ready.

> **This guide uses Docker mode** - everything runs in containers, no global CLI installations needed.
> For local mode (without Docker), see [Prerequisites](#prerequisites).

## 📚 OpenClaw Resources

**New to OpenClaw?** Learn more:
- **Official Docs:** https://docs.openclaw.ai
- **GitHub:** https://github.com/openclaw/openclaw
- **Installation Guide:** https://docs.openclaw.ai/getting-started
- **Discord Community:** https://discord.gg/openclaw

**This guide covers:** Setting up a 5-agent development team using OpenClaw in Docker mode.

---

## 🚀 Quick Start (Docker Mode - TL;DR)

The fastest path to get all 5 agents working with Docker:

> **No global installs needed!** OpenClaw, ClawHub, and tmux run inside containers.

```bash
# 1. Configure environment
cp .env.example .env
# Edit .env with your keys

# 2. Configure OpenClaw (automated setup)
make openclaw-config-setup   # Interactive setup with validation
# OR manually: cp .openclaw/openclaw.json.template .openclaw/openclaw.json

# 3. Start everything
make traefik-start          # Once per machine
make build && make start    # Build and start containers

# 4. Install dependencies
make dev-install            # Auto-installs pnpm + dependencies

# 5. Setup browser pairing (one command, auto-approves!)
make openclaw-pair-quick
# Follow on-screen instructions: copy token → open browser → paste token
# The command waits and auto-approves the pairing!

# 6. Login to ClawHub
docker exec -it ${PROJECT_NAME}-gateway npx clawhub login --token <token>

# 7. Install ALL skills (one command!)
make install-skills         # Installs 16+ skills for all agents

# 8. Create GitHub repo
gh repo create myproject --private --source=. --push

# 9. Test agents in Discord (or Web UI)
# @frontend, @backend, @qa, @tester - all ready!
```

**Total time:** ~15-20 minutes (most time is building Docker image)

---

## Prerequisites

> **What is OpenClaw?** A multi-agent AI platform for software development.
> See [OpenClaw Resources](#-openclaw-resources) for documentation and installation guides.

### Docker Mode (Recommended - Everything in Containers)

**Required:**
- Docker + Docker Compose v2
- GitHub CLI (`gh`) authenticated

**Optional:**
- Anthropic API key (for AI agents)
- ClawHub account (for skills)
- Discord bot token (for Discord chat)

**NOT needed** (already in containers):
- ❌ `npm install -g openclaw` - runs inside gateway container
- ❌ `pnpm add -g clawhub` - accessed via `docker exec ... npx clawhub`
- ❌ `brew install tmux` - already in dev-server container

---

### Local Mode (Without Docker)

If you prefer to run OpenClaw directly on your machine:

```bash
# Install OpenClaw CLI
npm install -g openclaw

# Install ClawHub CLI (for skills)
pnpm add -g clawhub

# Install tmux (optional, for monitoring)
brew install tmux  # macOS
apt install tmux   # Ubuntu/Debian
```

**Note:** This guide focuses on Docker mode. For local mode setup, see:
- Official guide: https://docs.openclaw.ai/installation
- Use `openclaw` commands instead of `make` commands

---

## Step 1: Configure `.env`

```bash
cp .env.example .env
```

Edit `.env`:

```bash
PROJECT_NAME=myproject
SSH_PORT=2222
DEV_USER=dev
DEV_USER_PASSWORD=<pick-a-strong-password>
GIT_USER_NAME=openclaw-5-agent-template
GIT_USER_EMAIL=bot@myorg.dev
ANTHROPIC_API_KEY=sk-ant-xxxx
GITHUB_TOKEN=ghp_xxxx
```

---

## Step 2: Configure OpenClaw

### 🎯 Automated Setup (Recommended)

Use the interactive setup script for guided configuration with validation:

```bash
make openclaw-config-setup
```

The script will:
- ✅ Prompt for Discord bot token, guild ID, user ID, and channel IDs
- ✅ Validate input format (checks Discord ID lengths)
- ✅ Auto-generate secure gateway auth token
- ✅ Create `.openclaw/openclaw.json` from template
- ✅ Set proper file permissions (600)
- ✅ Backup existing config if present

**What you'll need:**
1. **Discord Bot Token** - Get from [Discord Developer Portal](https://discord.com/developers/applications)
   - Create/select application → Bot → Reset Token
   - Enable "Message Content Intent" under Privileged Gateway Intents
2. **Guild ID** - Right-click your Discord server → Copy Server ID
3. **User ID** - Right-click your username → Copy User ID
4. **Channel IDs** - Right-click `#owner` and `#team` channels → Copy Channel ID

💡 **Tip:** Enable Developer Mode first: `Discord Settings → Advanced → Developer Mode ✅`

### 📝 Manual Setup (Alternative)

If you prefer to configure manually:

```bash
# Copy template to live config
cp .openclaw/openclaw.json.template .openclaw/openclaw.json
```

Edit `.openclaw/openclaw.json` and replace placeholders:

| Placeholder | Description | How to Get |
|-------------|-------------|------------|
| `<YOUR_DISCORD_BOT_TOKEN>` | Bot authentication token | Discord Developer Portal → Bot → Reset Token |
| `<YOUR_GUILD_ID>` | Discord server ID | Right-click server → Copy Server ID |
| `<YOUR_DISCORD_USER_ID>` | Your Discord user ID | Right-click username → Copy User ID |
| `<YOUR_OWNER_CHANNEL_ID>` | Private planning channel | Right-click #owner → Copy Channel ID |
| `<YOUR_TEAM_CHANNEL_ID>` | Public coordination channel | Right-click #team → Copy Channel ID |
| `<GENERATE_ON_FIRST_START>` | Gateway auth token | Run: `openssl rand -hex 24` |

Then set proper permissions:
```bash
chmod 600 .openclaw/openclaw.json
```

### 🚫 Skip Discord (Web UI Only)

If you don't want to use Discord, you can skip this step and use the web UI only. Just leave the template as-is and proceed to Step 3.

### 📚 Detailed Setup Guide

For comprehensive setup instructions, troubleshooting, and configuration details, see:
- **Detailed Guide:** `.openclaw/SETUP.md`
- **Quick Reference:** `.openclaw/CONFIG.md`

---

## Step 3: Start Traefik (once, shared across all projects)

```bash
make traefik-start
```

Verify: open http://traefik.localhost

---

## Step 4: Build & Start

```bash
make build          # builds dev-server image (~5 min first time)
make start          # starts dev-server + openclaw-gateway
```

---

## Step 5: Install dependencies

The template uses pnpm for better monorepo support. Install dependencies:

```bash
make dev-install     # Auto-installs pnpm if needed, then installs dependencies
```

This automatically installs pnpm (if not present) and installs all dependencies. Run again whenever you add/change dependencies.

---

## Step 6: Approve browser device

**🚀 Easiest Method - One Command Setup:**
```bash
make openclaw-pair-quick
```
This command will:
1. Show you the gateway token
2. Tell you to open http://${PROJECT_NAME}.openclaw.localhost
3. Guide you to paste the token in Settings (⚙️ icon)
4. **Auto-watch and approve** the pairing request
5. Confirm when successful ✅

**Alternative - Manual steps:**

If the browser shows "pairing required", run:
```bash
make openclaw-devices-auto-approve
```
This automatically finds and approves the pending device.

**Advanced - Watch mode:**
```bash
make openclaw-pair-watch
```
Continuously watches for pairing requests and auto-approves them. Useful if you're setting up multiple browsers.

**Example output:**
```
pairing_req_abc123xyz789  ← Easy to copy!
```

**Option 3: Manual (full JSON output)**
```bash
make openclaw-devices-list
# Find requestId in JSON output
make openclaw-devices-approve requestId=<paste-here>
```

Refresh the browser — you're in.

---

## Step 7: Login to ClawHub (for skills)

```bash
docker exec -it ${PROJECT_NAME}-gateway npx clawhub login
```

It shows a URL with a token like:

```
http://127.0.0.1:XXXXX/callback#token=clh_xxxxx...
```

The browser can't reach this inside Docker. Extract the token from the URL and run:

```bash
docker exec ${PROJECT_NAME}-gateway npx clawhub login --token clh_xxxxx...
```

---

## Step 8: Install skills

### Easy Way (Recommended) - One Command

```bash
# Installs ALL skills for ALL agents automatically
make install-skills
```

This installs 16+ skills across all agents:
- Shared: github-cli, github-ops, code-review
- Frontend: typescript, react-*, tailwind, accessibility
- Backend: nestjs, postgres-db, security-*
- Testing: testing-patterns, e2e-testing-patterns, devops

**Note:** Skills flagged as suspicious are skipped — add `--force` flag if needed.

### Alternative: Install by Category

If you hit rate limits, install in batches:

```bash
# Shared skills only (3 skills)
docker exec ${PROJECT_NAME}-gateway bash -c "cd /home/node/.openclaw/skills && \
  npx clawhub install github-ops typescript lb-zod-skill tmux"

# Frontend skills only (9 skills)
docker exec ${PROJECT_NAME}-gateway bash -c "cd /home/node/.openclaw/workspace-frontend/skills && \
  npx clawhub install react-expert react-best-practices react-performance tailwind-v4-shadcn"

# Backend skills only (4 skills)
docker exec ${PROJECT_NAME}-gateway bash -c "cd /home/node/.openclaw/workspace-backend/skills && \
  npx clawhub install nestjs security-auditor security-scanner"

# QA skills (3 skills)
docker exec ${PROJECT_NAME}-gateway bash -c "cd /home/node/.openclaw/workspace-qa-lead/skills && \
  npx clawhub install code-review security-auditor testing-patterns"

# Tester skills (3 skills)
docker exec ${PROJECT_NAME}-gateway bash -c "cd /home/node/.openclaw/workspace-tester/skills && \
  npx clawhub install testing-patterns e2e-testing-patterns playwright"
```

**Wait 1-2 minutes between batches if you see rate limit errors.**

---

## Step 9: Create GitHub repo

```bash
git init
git add .
git commit -m "initial: openclaw 5-agent dev team"
gh repo create openclaw-5-agent-template --private --source=. --push
```

Agents need a GitHub repo for branches and PRs.

---

## Step 10: Verify SSH (gateway → dev-server)

```bash
docker exec ${PROJECT_NAME}-gateway ssh dev@dev-server "echo OK"
```

If SSH client is missing in the gateway image:

```bash
docker exec ${PROJECT_NAME}-gateway apk add --no-cache openssh-client 2>/dev/null || \
docker exec ${PROJECT_NAME}-gateway apt-get install -y openssh-client 2>/dev/null
```

---

## Step 11: Connect Discord (optional)

Create a Discord bot at https://discord.com/developers/applications:

1. New Application → Bot → Reset Token → copy token
2. Bot settings: enable **Message Content Intent**
3. Invite bot to your server with `bot` + `applications.commands` scopes

Set the token:

```bash
make openclaw-discord-token token=YOUR_DISCORD_BOT_TOKEN
```

This updates `openclaw.json` and restarts the gateway automatically.

---

## Step 12: Start chatting

**Web UI:** Open http://${PROJECT_NAME}.openclaw.localhost

**Discord:** Message in your Discord server

Type:

> Hello @owner, are you ready?

Then assign a real task:

> I want a user authentication system with login and register

---

## Access Points

| Access | Protocol | How |
|--------|----------|-----|
| Code-server (IDE) | HTTP | http://${PROJECT_NAME}.code.localhost (via Traefik :80) |
| OpenClaw Web UI | HTTP | http://${PROJECT_NAME}.openclaw.localhost (via Traefik :80) |
| Traefik Dashboard | HTTP | http://traefik.localhost |
| Discord | Bot | Add bot to your Discord server |
| SSH to dev-server | TCP | `ssh dev-server-local` or `ssh -p 2222 dev@localhost` (direct, not via Traefik) |

Password for code-server and SSH: whatever you set in `DEV_USER_PASSWORD`.

### SSH shortcut (recommended)

Add this to your `~/.ssh/config` to avoid host key warnings after every rebuild:

```
Host dev-server-local
    HostName localhost
    Port 2222
    User dev
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

Then just: `ssh dev-server-local`

### tmux

A tmux session named `dev` auto-starts when the dev-server boots. After SSH:

```bash
tmux attach -t dev    # attach to the auto-started session
```

---

---

## Volume Mounts (Optimization)

The template uses optimized volume mounts for better security and performance:

| Container | Mounts | Why |
|-----------|--------|-----|
| **openclaw-gateway** | Full project (`./`) | Needs to edit all files, run git operations |
| **dev-server** | Only `apps/`, `packages/`, config | Only needs code for builds/tests |

**Dev-server has access to:**
- ✅ `apps/` - Application code
- ✅ `packages/` - Shared libraries
- ✅ `package.json`, `package-lock.json` - Workspace config
- ✅ `node_modules/` - Dependencies
- ❌ `.openclaw/`, `docs/`, `build/`, `.github/` - Not needed for builds

This reduces the attack surface and file watching overhead while keeping full functionality.

---

## Troubleshooting

### `pnpm test` / `pnpm run build` fails with binary errors

```bash
make dev-install     # Reinstall dependencies (auto-installs pnpm if needed)
```

### Gateway restart-looping

```bash
docker logs ${PROJECT_NAME}-gateway --tail 30
```

Common fixes:
- `gateway.mode` not set → must be `"local"` in openclaw.json
- `controlUi.allowedOrigins` missing → add `"dangerouslyAllowHostHeaderOriginFallback": true`
- Discord warnings → set `"channels": {}` if not using Discord
- Configuration errors → run `make openclaw-config-setup` to regenerate config

### `make dev-install` fails with "No such file or directory"

The command runs as root by default. Fixed in Makefile to use `-u dev` and absolute path `/home/dev/projects`.

### `git commit` "please tell me who you are"

Verify gateway has git env vars:

```bash
docker exec ${PROJECT_NAME}-gateway env | grep GIT
```

### SSH host verification blocks agents

`build/ssh-config` must be mounted with `StrictHostKeyChecking no`. Verify:

```bash
docker exec 0xthoth-gateway cat /home/node/.ssh/config
```

### Permission denied on `./data/`

```bash
make fix-data-permission
```

### ClawHub rate limited

Login first: `docker exec -it 0xthoth-gateway npx clawhub login`
Anonymous requests have very low rate limits (120/min). Authenticated gets 600/min.

### Skills install shows "suspicious" warning

Force install: add `--force` flag to the clawhub install command. These are usually false positives from documentation mentioning API keys.

### SSH "REMOTE HOST IDENTIFICATION HAS CHANGED" warning

Every `make build` creates a new container with a new SSH host key. Your Mac remembers the old key and warns you. Fix:

```bash
ssh-keygen -R "[localhost]:2222"
```

Or use the SSH shortcut config above (`StrictHostKeyChecking no`) to skip this permanently.

### Update Discord bot token

**Option 1: Update token only**
```bash
make openclaw-discord-token token=NEW_TOKEN_HERE
```

**Option 2: Re-run full setup (recommended if multiple values need updating)**
```bash
make openclaw-config-setup
```
This will backup your existing config and walk you through all configuration values.

Both options update `openclaw.json` and restart the gateway automatically.

### Stale socket file crashes dev-server on rebuild

If dev-server restart-loops after rebuild with `chown: Invalid argument` on a `.sock` file, the `start.sh` auto-cleans stale sockets. If it still happens:

```bash
rm -f data/dev/.local/share/code-server/code-server-ipc.sock
docker compose up -d dev-server
```

### Getting Help

**OpenClaw Issues:**
- Documentation: https://docs.openclaw.ai
- GitHub Issues: https://github.com/openclaw/openclaw/issues
- Discord: https://discord.gg/openclaw

**This Template Issues:**
- Check `.openclaw/CONFIG.md` for quick reference
- Review agent workflows in `.openclaw/workspace-*/AGENTS.md`
- Open issue in your project repository

---

## Multi-Agent System Setup

### Overview

This project uses **5 specialized AI agents** that work together:

| Agent | Model | Role | Git Email |
|-------|-------|------|-----------|
| **Owner** | Opus 4.6 | Project coordinator, task assignment | owner@team.com |
| **Frontend** | Sonnet 4.5 | React/TypeScript UI development | frontend@team.com |
| **Backend** | Sonnet 4.5 | NestJS API development, security | backend@team.com |
| **QA Lead** | Sonnet 4.5 | Code review, security audits | qa@team.com |
| **Tester** | Sonnet 4.5 | Testing, E2E automation, CI/CD | tester@team.com |

### Channel Setup

**Simplified (One Channel):**

All agents coordinate in **ONE Discord channel**:

```
Your Server
└── #team        ← All 5 agents work here
```

- **Owner responds by default** (no @mention needed)
- **Sub-agents respond when @mentioned**:
  - `@frontend` or `@fe` → Frontend agent
  - `@backend` or `@be` → Backend agent
  - `@qa` or `@qa-lead` → QA Lead agent
  - `@tester` or `@test` → Tester agent

### Agent Configuration

Each agent has:
- **Unique git identity** (commits show correct attribution)
- **Specialized skills** (shared + agent-specific)
- **Dedicated workspace** (`.openclaw/workspace-<agent>/`)
- **Learning system** (`.learnings/` to avoid past mistakes)

### Skills Distribution

**Shared (all agents):**
- typescript, github-ops, lb-zod-skill, tmux

**Owner-specific:**
- code-review, devops

**Frontend-specific:**
- react-expert, react-best-practices, react-performance, tailwind-v4-shadcn, sovereign-accessibility-auditor

**Backend-specific:**
- nestjs, security-auditor, security-scanner

**QA-specific:**
- code-review, security-auditor, testing-patterns

**Tester-specific:**
- testing-patterns, e2e-testing-patterns, playwright

### Testing Agents

In your **#team** channel:

```
Test 1: Owner (default, no @mention)
You: Hello
Owner: Hello! Ready to coordinate the team.

Test 2: Frontend
You: @frontend what can you do?
Frontend: I specialize in React/TypeScript UI development...

Test 3: Backend
You: @backend what are your skills?
Backend: I handle NestJS API development...

Test 4: QA Lead
You: @qa hello
QA: I perform code reviews and security audits...

Test 5: Tester
You: @tester hi
Tester: I run tests and E2E automation...
```

### Typical Workflow

```
1. Human: "I need a login feature"
   ↓
2. Owner: Creates GitHub issues
   - #123: Frontend login form
   - #124: Backend auth API
   ↓
3. Owner: "@frontend implement #123"
   Owner: "@backend implement #124"
   ↓
4. Frontend & Backend: Work on feature branches
   - feat/fe-login-form
   - feat/be-auth-api
   ↓
5. Frontend: "PR #45 ready. @owner @qa"
   Backend: "PR #46 ready. @owner @qa"
   ↓
6. QA Lead: Reviews PRs
   ↓
7. Owner: "@tester run E2E tests"
   ↓
8. Tester: Runs tests, reports results
   ↓
9. Owner: Merges PRs if tests pass
```

### Agent Skills Update

```bash
# Update all skills (Docker mode)
make update-skills

# Or individually
docker exec ${PROJECT_NAME}-gateway bash -c \
  "cd /home/node/.openclaw/skills && npx clawhub update --all"
```

### Monitoring with Tmux

Agents can use tmux for long-running processes:

```bash
# Socket location
SOCKET_DIR="${TMPDIR:-/tmp}/clawdbot-tmux-sockets"
SOCKET="$SOCKET_DIR/clawdbot.sock"

# Available sessions (agents create these)
# - owner-coordination
# - frontend-dev
# - backend-dev
# - tester-work

# Attach to watch agent work
tmux -S "$SOCKET" attach -t frontend-dev

# Detach (agent keeps working)
Ctrl+B, then D
```

### Git Attribution

Each agent automatically configures git identity on session start:

```bash
# Verify agent commits show correct attribution
git log --format="%an <%ae>" | sort -u

# Expected output:
# Owner Agent <owner@team.com>
# Frontend Dev Agent <frontend@team.com>
# Backend Dev Agent <backend@team.com>
# QA Lead Agent <qa@team.com>
# Tester Agent <tester@team.com>
```

### Agent Troubleshooting

**Agent not responding:**
```bash
# Check gateway is running
make openclaw-restart

# Check agent configuration
openclaw agents list
```

**Skills not loading:**
```bash
# Update skills
make update-skills

# Restart gateway
make openclaw-restart
```

**Wrong git attribution:**
```bash
# Check agent's AGENTS.md for git config
cat .openclaw/workspace-frontend/AGENTS.md | grep "git config"

# Each agent should have:
# git config user.name "<Agent> Agent"
# git config user.email "<agent>@team.com"
```

### Agent Documentation

- **Quick Reference:** `.openclaw/CONFIG.md`
- **Architecture:** `.openclaw/ARCHITECTURE.md`
- **Agent Workflows:** `.openclaw/workspace-*/AGENTS.md`
- **Agent Template:** `.openclaw/workspace-owner/AGENT-TEMPLATE.md`

### Makefile Commands for Agents

```bash
# Configuration
make openclaw-config-setup  # Interactive setup for openclaw.json (Docker mode)

# Gateway control
make openclaw-restart       # Restart gateway (Docker mode)
make gateway-restart        # Restart gateway (Local mode)

# Device management
make openclaw-pair-quick            # Quick setup: shows token + auto-approves (EASIEST!)
make openclaw-pair-watch            # Watch and auto-approve pairing requests
make openclaw-devices-auto-approve  # Auto-approve pending device
make openclaw-devices-list          # List pending/paired devices
make openclaw-gateway-token         # Show gateway authentication token

# Skills
make install-skills         # Install all skills (Docker mode)
make update-skills          # Update all skills (Docker mode)
make update-skills-local    # Update all skills (Local mode)

# Status
make status                 # Show running containers
make gateway-status         # Show gateway status (Local mode)
make agents-list            # List configured agents (Local mode)
```
