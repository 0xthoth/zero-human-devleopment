# OpenClaw 5-Agent Development Team Template

A production-ready multi-agent system for collaborative software development using OpenClaw.

> **🐳 Docker Mode (Recommended):** See `/SETUP-GUIDE.md` for complete Docker setup
>
> **💻 Local Mode:** This README shows local mode setup (OpenClaw installed globally)

## Features

- **5 Specialized Agents:** Owner (coordinator), Frontend, Backend, QA Lead, Tester
- **Per-Agent Channel Routing:** Each agent has its own Discord channel for focused work
- **Skill Distribution:** Shared skills (all agents) + agent-specific skills
- **Git Identity:** Each agent commits with unique identity
- **CI/CD Integration:** Playwright E2E testing with full CI/CD workflow
- **Learning System:** Agents learn from past mistakes (.learnings/)

---

## Quick Reference

### 5 Agents
- **owner** (default) - Opus 4.6 - Coordination
- **frontend** - Sonnet 4.5 - React/UI development
- **backend** - Sonnet 4.5 - NestJS/API development
- **qa-lead** - Sonnet 4.5 - Code review
- **tester** - Sonnet 4.5 - Testing + Playwright CI/CD

### Git Identities
```
owner@team.com, frontend@team.com, backend@team.com, qa@team.com, tester@team.com
```

### Skills Distribution

**Shared (5 skills)** - `.openclaw/skills/`
- typescript, github-ops, lb-zod-skill, tmux ✅

**Per-Agent Skills:**
- **Owner:** code-review, devops
- **Frontend:** react-expert, react-best-practices, react-performance, tailwind-v4-shadcn, sovereign-accessibility-auditor
- **Backend:** nestjs, security-auditor, security-scanner
- **QA Lead:** code-review, security-auditor, testing-patterns
- **Tester:** testing-patterns, e2e-testing-patterns, playwright

---

## Quick Start

> **📖 Full Setup Guide:** See `/SETUP-GUIDE.md` for complete Docker mode setup (recommended)
>
> **This guide shows LOCAL mode** - running OpenClaw directly on your machine without Docker.

### 1. Prerequisites (Local Mode)
```bash
# Install OpenClaw CLI
npm install -g openclaw

# Install ClawHub CLI
pnpm add -g clawhub

# Install tmux (for monitoring)
brew install tmux  # macOS
apt install tmux   # Ubuntu/Debian
```

**For Docker mode:** Skip these installs and follow `/SETUP-GUIDE.md` instead.

### 2. Configure Discord Bot
1. Create Discord server with these channels:
   - `#general` - Human ↔ Owner (owner's primary channel)
   - `#team` - Status board (owner monitors for coordination)
   - `#fe` - Frontend agent's dedicated channel
   - `#be` - Backend agent's dedicated channel
   - `#tt` - Tester agent's dedicated channel
   - `#qa` - QA Lead agent's dedicated channel
2. Create Discord bot at https://discord.com/developers
   - Enable "Message Content Intent" in Bot settings
   - Get bot token
3. Get your Discord IDs:
   - Guild ID (Server ID): Right-click server → Copy ID
   - Channel IDs for each channel above
   - Your User ID: Right-click your name → Copy ID
4. Update IDs in `openclaw.json.template`

See `docs/DISCORD-SETUP.md` for detailed setup instructions.

### 3. Setup Configuration
```bash
# Copy template to live config
cp .openclaw/openclaw.json.template .openclaw/openclaw.json

# Edit openclaw.json and replace placeholders:
# - <YOUR_DISCORD_BOT_TOKEN>       → Your bot token
# - <YOUR_GUILD_ID>                → Your Discord server ID
# - Channel IDs for #general, #team, #fe, #be, #tt, #qa
# - <YOUR_DISCORD_USER_ID>         → Your Discord user ID
```

### 4. Install Skills
```bash
# Update all skills to latest versions
make update-skills-local
```

### 5. Start Gateway
```bash
make gateway-restart
# or: openclaw gateway restart
```

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USER (Discord)                                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
        ┌──────────┬──────────┬───────┴───────┬──────────┬──────────┐
        │          │          │               │          │          │
   ┌────▼────┐ ┌───▼───┐ ┌───▼───┐     ┌─────▼───┐ ┌───▼───┐ ┌───▼───┐
   │#general │ │ #team │ │  #fe  │     │   #be   │ │  #tt  │ │  #qa  │
   │ Owner   │ │Status │ │Front  │     │  Back   │ │Tester │ │  QA   │
   │ primary │ │ board │ │  end  │     │  end    │ │       │ │ Lead  │
   └────┬────┘ └───┬───┘ └───┬───┘     └────┬────┘ └───┬───┘ └───┬───┘
        │          │          │               │          │          │
        └──────────┴──────────┴───────┬───────┴──────────┴──────────┘
                                      │
        ┌─────────────────────────────┴─────────────────────────────┐
        │                    OpenClaw Gateway                        │
        │                  (Channel Router)                          │
        └─────────────────────────────┬─────────────────────────────┘
                                      │
    ┌─────────────────────────────────┼─────────────────────────────────┐
    │                                 │                                 │
    │                        Agent Resolution                          │
    │  Per-Agent Channel Routing:                                      │
    │  #general → Owner (requireMention: false)                        │
    │  #team   → Owner monitors (status board)                         │
    │  #fe     → Frontend (requireMention: false)                      │
    │  #be     → Backend (requireMention: false)                       │
    │  #tt     → Tester (requireMention: false)                        │
    │  #qa     → QA Lead (requireMention: false)                       │
    │                                                                  │
    └─────────────────────────────────┬─────────────────────────────────┘
                                      │
        ┌────────────────────────────┴────────────────────────────┐
        │                                                          │
        │                     5 AGENTS                             │
        │                                                          │
        ├──────────────────┬──────────────┬──────────────────────┤
        │                  │              │                      │
┌───────▼────────┐  ┌──────▼──────┐  ┌──▼─────────┐  ┌─────────▼────────┐
│ OWNER          │  │ FRONTEND    │  │ BACKEND    │  │ QA LEAD / TESTER │
│                │  │             │  │            │  │                  │
│ Opus 4.6       │  │ Sonnet 4.5  │  │ Sonnet 4.5 │  │ Sonnet 4.5       │
│ #general+#team │  │ #fe         │  │ #be        │  │ #qa / #tt        │
└───────┬────────┘  └──────┬──────┘  └──┬─────────┘  └─────────┬────────┘
        │                  │             │                      │
        └──────────────────┴─────────────┴──────────────────────┘
                                     │
                          ┌──────────▼──────────┐
                          │   SHARED SKILLS     │
                          │  (.openclaw/skills) │
                          │                     │
                          │  • typescript       │
                          │  • github-ops       │
                          │  • lb-zod-skill     │
                          │  • tmux ✅          │
                          └──────────┬──────────┘
                                     │
        ┌────────────────────────────┴─────────────────────────────┐
        │                                                           │
        │              AGENT-SPECIFIC SKILLS                        │
        │          (.openclaw/workspace-*/skills)                   │
        │                                                           │
        ├─────────────┬──────────────┬──────────────┬─────────────┤
        │             │              │              │             │
┌───────▼────────┐ ┌──▼──────────┐ ┌▼───────────┐ ┌▼────────────┐
│ OWNER SKILLS   │ │ FRONTEND    │ │ BACKEND    │ │ TESTER      │
│                │ │ SKILLS      │ │ SKILLS     │ │ SKILLS      │
│ • code-review  │ │ • react-*   │ │ • nestjs   │ │ • testing-* │
│ • devops       │ │ • tailwind  │ │ • security │ │ • playwright│
└────────────────┘ │ • a11y      │ └────────────┘ └─────────────┘
                   └─────────────┘
```

### Skill Priority Hierarchy

```
┌─────────────────────────────────────┐
│   WORKSPACE SKILLS (Agent-Specific) │  ← Highest Priority
│   .openclaw/workspace-*/skills/     │
└─────────────────┬───────────────────┘
                  │
                  │ overrides
                  ↓
┌─────────────────────────────────────┐
│      MANAGED SKILLS (Shared)        │
│      .openclaw/skills/              │
└─────────────────┬───────────────────┘
                  │
                  │ overrides
                  ↓
┌─────────────────────────────────────┐
│    BUNDLED SKILLS (OpenClaw)        │  ← Lowest Priority
│    Built-in to OpenClaw             │
└─────────────────────────────────────┘
```

## Channel Routing

### Per-Agent Channel Routing

Each agent has its own dedicated Discord channel. All channels use `requireMention: false` — agents respond to ALL messages in their channel.

| Channel | Agent | Purpose |
|---------|-------|---------|
| `#general` | Owner | Human ↔ Owner direct conversation, planning |
| `#team` | Owner (monitors) | Status board, coordination visibility |
| `#fe` | Frontend | Frontend development tasks |
| `#be` | Backend | Backend development tasks |
| `#tt` | Tester | Testing and CI/CD tasks |
| `#qa` | QA Lead | Code review and quality tasks |

**Why per-agent channels?**
- ✅ Each agent has focused context in its own channel
- ✅ No @mention routing needed — agents respond to everything in their channel
- ✅ Clear separation of concerns
- ✅ Easy to track each agent's work history
- ✅ Owner monitors #team for cross-agent coordination

## Workflow Example

```
#general:
  Human: "I need a login feature"
  Owner: "Let me create the issues..."

#fe:
  Owner: "Implement login form #123"
  Frontend: "✅ Working on it..."
  Frontend: "PR #45 ready for review"

#be:
  Owner: "Add auth API #124"
  Backend: "✅ Working on it..."
  Backend: "PR #46 ready"

#qa:
  Owner: "Review PR #45 and #46"
  QA: "✅ Approved both PRs"

#tt:
  Owner: "Run E2E tests for login"
  Tester: "✅ 25/25 tests passed"

#general:
  Owner: "Login feature shipped ✅"
```

---

## Common Commands

### Gateway
```bash
make gateway-restart        # Restart gateway
make gateway-status         # Check status
make agents-list            # List all agents
```

### Skills
```bash
# Update all skills
make update-skills-local    # Local mode (no Docker)
make update-skills          # Docker mode

# Install shared skill
cd .openclaw/skills && clawhub install <skill>

# Install for specific agent
cd .openclaw/workspace-<agent>/skills && clawhub install <skill>
```

### Verification
```bash
make verify                 # Verify before Git push
make help                   # Show all Makefile commands
```

---

## Customization

### Adding New Agents
1. Read `workspace-owner/AGENT-TEMPLATE.md`
2. Create new workspace directory
3. Add agent to `openclaw.json`
4. Create a dedicated Discord channel for the agent
5. Add channel binding in config
6. Restart gateway

### Adding Skills
```bash
# Shared skill (all agents)
cd .openclaw/skills && clawhub install <skill>

# Agent-specific skill
cd .openclaw/workspace-<agent>/skills && clawhub install <skill>
```

### Updating Workflows
Edit `.openclaw/workspace-*/AGENTS.md` for each agent's specific workflow.

## File Structure

```
.openclaw/
├── README.md                    # This file
├── openclaw.json.template       # Configuration template
│
├── skills/                      # Shared skills (all agents)
│   ├── typescript/
│   ├── github-ops/
│   ├── lb-zod-skill/
│   └── tmux/
│
├── shared/                      # Shared docs for all agents
│   ├── TEAM-RULEBOOK.md
│   ├── TOOLS-COMMON.md
│   └── USER.md
│
├── agents/                      # Runtime agent directories
│   ├── owner/agent/
│   ├── frontend/agent/
│   ├── backend/agent/
│   ├── qa-lead/agent/
│   ├── tester/agent/
│   └── main/agent/
│
├── workspace-owner/
│   ├── AGENT-TEMPLATE.md        # Template for new agents
│   ├── AGENTS.md                # Workflows
│   ├── IDENTITY.md, SOUL.md     # Agent personality
│   └── skills/                  # Owner-specific skills
│
├── workspace-frontend/
├── workspace-backend/
├── workspace-qa-lead/
└── workspace-tester/
```

## Troubleshooting

See `docs/TROUBLESHOOTING.md` for common issues and solutions.

## Contributing

This template is designed to be forked and customized:
1. Fork this repository
2. Customize agent roles and skills
3. Add your own workflows
4. Share your improvements!

## License

MIT License - See LICENSE file

## Resources

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [ClawHub Skills Registry](https://clawhub.ai)
- [Discord Bot Setup](https://discord.com/developers/applications)
