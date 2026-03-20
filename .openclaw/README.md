# OpenClaw 5-Agent Development Team Template

A production-ready multi-agent system for collaborative software development using OpenClaw.

> **🐳 Docker Mode (Recommended):** See `/SETUP-GUIDE.md` for complete Docker setup
>
> **💻 Local Mode:** This README shows local mode setup (OpenClaw installed globally)

## Features

- **5 Specialized Agents:** Owner (coordinator), Frontend, Backend, QA Lead, Tester
- **Two-Channel Strategy:** #owner (private) + #team (public coordination)
- **Skill Distribution:** Shared skills (all agents) + agent-specific skills
- **Git Identity:** Each agent commits with unique identity
- **CI/CD Integration:** Playwright E2E testing with full CI/CD workflow
- **Complete Activity Tracking:** Monitor both agent thinking (Gateway) and execution (Dev-Server) 🔍
  - See [COMPLETE-TRACKING-GUIDE.md](COMPLETE-TRACKING-GUIDE.md) for full details
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
1. Create Discord server with **TWO channels**:
   - `#owner` - Private planning (human ↔ owner)
   - `#team` - Public coordination (all agents)
2. Create Discord bot at https://discord.com/developers
   - Enable "Message Content Intent" in Bot settings
   - Get bot token
3. Get your Discord IDs:
   - Guild ID (Server ID): Right-click server → Copy ID
   - Owner Channel ID: Right-click #owner → Copy ID
   - Team Channel ID: Right-click #team → Copy ID
   - Your User ID: Right-click your name → Copy ID
4. Update IDs in `openclaw.json.template`

See `docs/TEMPLATE-SETUP-GUIDE.md` for detailed setup instructions.

### 3. Setup Configuration
```bash
# Copy template to live config
cp .openclaw/openclaw.json.template .openclaw/openclaw.json

# Edit openclaw.json and replace placeholders:
# - <YOUR_DISCORD_BOT_TOKEN>       → Your bot token
# - <YOUR_GUILD_ID>                → Your Discord server ID
# - <YOUR_OWNER_CHANNEL_ID>        → Your #owner channel ID (private)
# - <YOUR_TEAM_CHANNEL_ID>         → Your #team channel ID (public)
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
                    ┌─────────────────┴─────────────────┐
                    │                                   │
            ┌───────▼────────┐                 ┌────────▼────────┐
            │ #owner Channel │                 │  #team Channel  │
            │ (1483684870..) │                 │  (1483721..)    │
            │                │                 │                 │
            │ Private        │                 │ Public          │
            │ Human ↔ Owner  │                 │ Coordination    │
            │ No @mention    │                 │ All agents      │
            └────────────────┘                 └────────┬────────┘
                    │                                   │
                    └─────────────────┬─────────────────┘
                                      │
        ┌─────────────────────────────┴─────────────────────────────┐
        │                    OpenClaw Gateway                        │
        │                  (Channel Router)                          │
        └─────────────────────────────┬─────────────────────────────┘
                                      │
    ┌─────────────────────────────────┼─────────────────────────────────┐
    │                                 │                                 │
    │                        Agent Resolution                          │
    │  #owner: requireMention=false → Owner always responds            │
    │  #team: requireMention=true → Owner (default) + @mentioned agents│
    │  Auto-reply routing: Reply in channel where msg received         │
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
│ Default: true  │  │             │  │            │  │                  │
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

### Two-Channel Strategy

**#owner (Private Planning)**
- Human ↔ Owner direct conversation
- No @mention needed
- Private planning and strategy

**#team (Public Coordination)**
- Owner sees ALL messages (default agent)
- Sub-agents respond when @mentioned:
  - `@frontend` or `@fe` - Frontend agent
  - `@backend` or `@be` - Backend agent
  - `@qa` or `@qa-lead` - QA Lead agent
  - `@tester` or `@test` - Tester agent
- Full transparency of team workflow

**Why two channels?**
- ✅ Separate private planning from public coordination
- ✅ Owner responds automatically in both channels
- ✅ Sub-agents only in #team (cleaner separation)
- ✅ Full visibility without noise

See `docs/TWO-CHANNEL-SETUP.md` for complete details.

## Workflow Example

```
#owner (Private):
  Human: "I need a login feature"
  Owner: "Let me create the issues..."

#team (Public):
  Owner: "@frontend implement login form #123"
  Owner: "@backend add auth API #124"
    ↓
  Frontend: "✅ Working on #123"
  Backend: "✅ Working on #124"
    ↓
  Frontend: "@owner @qa PR #45 ready"
    ↓
  QA: "✅ Approved PR #45"
    ↓
  Owner: "@tester run E2E tests"
  Tester: "✅ 25/25 tests passed"
    ↓
  Owner: "Merged! Login feature complete."
```

### Data Flows

**Testing Flow (with Playwright CI/CD)**
```
Tester receives @mention
    ↓
Run local tests: npx playwright test
    ↓
Monitor CI: gh run list
    ↓
Capture artifacts: screenshots, videos, traces
    ↓
Debug failures: npx playwright show-trace
    ↓
Report in #team:
    🎭 Playwright E2E Report
    ✅ Passed: X
    ❌ Failed: Y
    Screenshots & traces attached
```

**Code Review Flow**
```
PR created by Frontend/Backend
    ↓
Owner @mentions QA Lead
    ↓
QA reviews code (code-review skill)
    ↓
Submit GitHub review
    ↓
Report summary in #team
    ↓
Owner merges if approved
```

**Git Flow**
```
Agent Session Starts
    ↓
git config user.name "<Agent> Agent"
git config user.email "<agent>@team.com"
    ↓
Agent creates commits
Author: Frontend Dev Agent <frontend@team.com>
    ↓
GitHub shows correct agent attribution
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
4. Add Discord channel binding
5. Restart gateway

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
├── CONFIG.md                    # Quick reference
├── ARCHITECTURE.md              # System diagrams
├── README.md                    # This file
├── openclaw.json.template       # Configuration template
│
├── docs/                        # Implementation guides
│   ├── TMUX-IMPLEMENTATION.md   # Tmux monitoring ✅
│   ├── TWO-CHANNEL-SETUP.md     # Channel strategy
│   └── TEMPLATE-SETUP-GUIDE.md  # Template setup
│
├── archive/                     # Historical docs
│   ├── IMPLEMENTATION-SUMMARY.md
│   └── TEMPLATE-UPDATED.md
│
├── skills/                      # Shared skills (all agents)
│   ├── typescript/
│   ├── github-ops/
│   ├── lb-zod-skill/
│   └── tmux/                    # ✅ Enabled
│
├── workspace-owner/
│   ├── AGENT-TEMPLATE.md        # Template for new agents
│   ├── AGENTS.md                # Workflows (with tmux)
│   ├── IDENTITY.md, SOUL.md     # Agent personality
│   └── skills/                  # Owner-specific skills
│
├── workspace-frontend/          # Tmux workflows ✅
├── workspace-backend/           # Tmux workflows ✅
├── workspace-qa-lead/
└── workspace-tester/            # Tmux workflows ✅
```

## CI/CD Integration

### Playwright E2E Testing (Tester Agent)
```bash
# Run E2E tests
npx playwright test

# Monitor CI
gh run list --workflow="E2E Tests"

# Debug with traces
npx playwright show-trace trace.zip
```

### GitHub Actions
Add workflows in `.github/workflows/`:
- `ci.yml` - Run tests on PR
- `e2e.yml` - Playwright E2E tests

## Monitoring

### Complete Activity Tracking 🔍

Track agents at **two levels** for complete visibility:

1. **Gateway (Agent Brain 🧠)** - What agents think and decide
2. **Dev-Server (Execution ⚙️)** - What commands actually run

**Quick commands:**
```bash
# Gateway tracking - see agent thinking
make agent-sessions                    # List all conversations
make agent-session-view agent=owner    # View latest session

# Dev-server tracking - see command execution
make tmux-list                        # List all tmux sessions
make tmux-watch agent=frontend        # Watch frontend terminal

# Watch BOTH at once (split screen)
make agent-watch-all agent=backend    # Best for active monitoring
```

**Full guides:**
- **[COMPLETE-TRACKING-GUIDE.md](COMPLETE-TRACKING-GUIDE.md)** - Complete guide to both levels
- **[GATEWAY-TRACKING.md](GATEWAY-TRACKING.md)** - Gateway-level tracking (thinking)
- **[AGENT-TMUX-TRACKING.md](AGENT-TMUX-TRACKING.md)** - Dev-server tracking (execution)

### Legacy Tmux Sessions (Local Mode)

For local mode installations, use the tmux socket approach:

```bash
# Setup socket
SOCKET_DIR="${TMPDIR:-/tmp}/clawdbot-tmux-sockets"
SOCKET="$SOCKET_DIR/clawdbot.sock"

# List active sessions
tmux -S "$SOCKET" list-sessions

# Attach to agent's work (watch in real-time)
tmux -S "$SOCKET" attach -t frontend-dev

# Detach (keeps session running)
# Press: Ctrl+b then d

# View output without attaching
tmux -S "$SOCKET" capture-pane -p -J -t frontend-dev:0.0 -S -200
```

See `docs/TMUX-IMPLEMENTATION.md` for complete guide.

### Logs
```bash
# Gateway logs
make gateway-logs

# Agent-specific logs (if available)
tail -f .openclaw/logs/<agent>.log
```

## Troubleshooting

### Rate Limits
**ClawHub:** 120 req/min. Wait 1-2 minutes between operations.

### Skills in Wrong Location
If installed to `skills/skills/<skill>`:
```bash
mv skills/skills/<skill> .
```

### Config Not Applying
Always restart gateway after config changes:
```bash
openclaw gateway restart
# or: make gateway-restart
```

### Agent Not Responding
- Check mention patterns in `openclaw.json`
- Verify bindings include the channel
- Check if agent is default (owner only)
- Verify channel `requireMention` settings

### Tmux Session Not Found
- Verify tmux skill is installed: `ls .openclaw/skills/tmux`
- Check if skill is enabled in `openclaw.json`
- Restart gateway after enabling

## Contributing

This template is designed to be forked and customized:
1. Fork this repository
2. Customize agent roles and skills
3. Add your own workflows
4. Share your improvements!

## License

MIT License - See LICENSE file

## Documentation

**Everything in one place:**
- **This file (README.md):** Quick reference, architecture, commands, troubleshooting

**Deep-dive guides:**
- `docs/TEMPLATE-SETUP-GUIDE.md` - Setting up new project
- `docs/TMUX-IMPLEMENTATION.md` - Tmux monitoring details
- `docs/TWO-CHANNEL-SETUP.md` - Channel strategy details

**Templates:**
- `openclaw.json.template` - New project template
- `workspace-owner/AGENT-TEMPLATE.md` - New agent template

**Historical reference:**
- `archive/` - Completed work logs

## Resources

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [ClawHub Skills Registry](https://clawhub.ai)
- [Discord Bot Setup](https://discord.com/developers/applications)

## Support

For issues and questions:
- OpenClaw: https://github.com/anthropics/openclaw
- Template Issues: [Your repo issues page]
