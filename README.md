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
