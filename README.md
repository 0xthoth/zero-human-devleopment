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
- 🛠️ **Smart Skill Distribution** - Shared + agent-specific skills
- 🎭 **Git Identity** - Each agent commits with unique identity
- 🧪 **Playwright CI/CD** - Full E2E testing integration
- 📺 **Tmux Monitoring** - Watch agents work in real-time
- 🧠 **Learning System** - Agents learn from past mistakes

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

Have an existing codebase? You can use this template as the AI team layer:

### 1. Clone template + add your code

```bash
git clone https://github.com/0xthoth/zero-human-devleopment.git my-project
cd my-project
rm -rf apps/* packages/*

# Monorepo: copy your apps
cp -r ~/existing-project/apps/* apps/
cp -r ~/existing-project/packages/* packages/

# Single app: put it in apps/web
mkdir -p apps/web
cp -r ~/existing-project/* apps/web/
```

### 2. Update agent knowledge

Edit these files to match your tech stack:
- `.openclaw/workspace-frontend/SOUL.md` — framework, styling, patterns
- `.openclaw/workspace-backend/SOUL.md` — API framework, database, auth
- `.openclaw/shared/TEAM-RULEBOOK.md` — project structure, conventions

### 3. Adjust Docker mounts (if needed)

The template mounts `./apps` and `./packages` into containers. If your project has additional root config files, add them to `docker-compose.yml`:

```yaml
# dev-server + gateway volumes:
- ./tsconfig.json:/home/dev/project/tsconfig.json:ro
- ./.eslintrc.js:/home/dev/project/.eslintrc.js:ro
- ./turbo.json:/home/dev/project/turbo.json:ro
```

### 4. Package manager

Template uses **pnpm**. If your project uses npm/yarn:
- Option A: Convert to pnpm (`pnpm import`)
- Option B: Change scripts in `package.json` and `Makefile` to use npm/yarn

### 5. Setup as normal

```bash
make init
make openclaw-config-setup
make start
```

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
