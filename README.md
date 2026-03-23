# OpenClaw 5-Agent Development Team

> A production-ready multi-agent system template for collaborative software development

## 🎯 What is This?

A complete OpenClaw configuration featuring 5 specialized AI agents working together to build software:

- **Owner** (Opus 4.6) - Project coordinator and architect
- **Frontend** (Sonnet 4.5) - React/TypeScript UI development
- **Backend** (Sonnet 4.5) - NestJS API development
- **QA Lead** (Sonnet 4.5) - Code review and security
- **Tester** (Sonnet 4.5) - Testing and CI/CD automation

## ✨ Features

- 🎯 **Per-Agent Channel Routing** - Each agent has its own Discord channel (#fe, #be, #tt, #qa), no @mention needed
- 🔀 **Git Worktrees** - Agents work in parallel on different branches without conflicts
- 🛠️ **Smart Skill Distribution** - Shared + agent-specific skills
- 🎭 **Git Identity** - Each agent commits with unique identity (auto-configured per worktree)
- 🧪 **Playwright CI/CD** - Full E2E testing integration
- 📺 **Tmux Monitoring** - Watch agents work in real-time
- 🧠 **Learning System** - Agents learn from past mistakes
- 👥 **Multi-Team Ready** - Multiple OpenClaw instances can share the same repo via Git

## 🚀 Quick Start

See [.openclaw/README.md](.openclaw/README.md) for complete setup instructions.

## 📋 Discord Channels

| Channel | Agent | Purpose |
|---------|-------|---------|
| `#general` | Owner | Human ↔ Owner planning |
| `#team` | Owner (monitors) | Status board |
| `#fe` | Frontend | Frontend tasks |
| `#be` | Backend | Backend tasks |
| `#tt` | Tester | Testing tasks |
| `#qa` | QA Lead | Code review |

## 📦 Using with an Existing Project

Have an existing codebase? Use this as the AI team layer:

1. Fork/clone this repo
2. Replace `apps/` and `packages/` with your code
3. Update `.openclaw/workspace-*/SOUL.md` to match your tech stack
4. `make init` → `make start`

### Adjust Docker mounts (if needed)

Add extra root config files to `docker-compose.yml`:

```yaml
- ./tsconfig.json:/home/dev/project/tsconfig.json:ro
- ./.eslintrc.js:/home/dev/project/.eslintrc.js:ro
```

### Package manager

This project uses **pnpm**. To convert from npm/yarn: `pnpm import`

## 🔄 Updating from Template

```bash
# Setup (once)
git remote add template https://github.com/0xthoth/zero-human-devleopment.git

# When template has updates
git fetch template
git checkout -b chore/template-update
git checkout template/master -- build/ Makefile docker-compose.yml scripts/ docs/
git add -A
git commit -m "chore: update infra from template"
# Create PR → review → merge
```

### Safe to update from template
`build/`, `Makefile`, `scripts/`, `docs/`, `docker-compose.yml`

### Must merge manually
`docker-compose.yml` (if you changed ports), `.openclaw/workspace-*/SOUL.md`, `.gitignore`, `package.json`

### Never overwrite
`apps/`, `packages/`, `.env`, `.openclaw/openclaw.json`, `.openclaw/workspace-*/memory/`

## 🔀 Git Worktrees (Parallel Development)

Agents use Git Worktrees to work simultaneously on different branches:

```
~/project/              ← main branch (human works here)
~/worktrees/
├── frontend/           ← feat/fe-xxx (Frontend agent)
├── backend/            ← feat/be-xxx (Backend agent)
└── tester/             ← feat/tt-xxx (Tester agent)
```

**Helper script:**
```bash
# Create worktree (auto-installs deps + sets git identity)
scripts/worktree.sh create frontend feat/fe-login

# List active worktrees
scripts/worktree.sh list

# Remove after PR is created
scripts/worktree.sh remove frontend

# Clean all worktrees
scripts/worktree.sh clean
```

**Benefits:**
- ✅ All agents work in parallel — no branch conflicts
- ✅ Human + agents can code at the same time
- ✅ Git identity auto-configured per agent
- ✅ Worktrees cleaned up after PR creation

## 👥 Multi-Team Collaboration

Multiple teams (each with their own OpenClaw instance) can work on the same project:

```
Team A (Dev)              Team B (Design)
├── OpenClaw Instance A   ├── OpenClaw Instance B
├── Own agents & config   ├── Own agents & config
├── Own API keys          ├── Own API keys
└── feat/dev-xxx          └── feat/design-xxx
         │                         │
         └──── Same GitHub Repo ───┘
                     │
                   PRs + Review
```

Each team just clones the repo, sets up their own `.env` and agents, and collaborates via Git PRs.

## 📚 Documentation

- [Setup Guide](.openclaw/README.md) — Full setup and architecture
- [Discord Setup](docs/DISCORD-SETUP.md) — Bot and channel configuration
- [Troubleshooting](docs/TROUBLESHOOTING.md) — Common issues and fixes
- [Multi-Project Setup](docs/MULTI-PROJECT.md) — Running multiple projects
- [Agent Template](.openclaw/workspace-owner/AGENT-TEMPLATE.md) — Adding new agents

## 📜 License

MIT License

---

**Made with Claude Code** - A multi-agent development system
