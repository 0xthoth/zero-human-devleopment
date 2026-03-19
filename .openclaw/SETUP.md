# OpenClaw Configuration Setup Guide

This guide explains how to set up your OpenClaw multi-agent system from the template configuration.

## Quick Start

### Prerequisites

1. **Discord Bot Setup**
   - Go to [Discord Developer Portal](https://discord.com/developers/applications)
   - Create a new application or use an existing one
   - Navigate to the "Bot" section
   - Enable these Privileged Gateway Intents:
     - ✅ Presence Intent
     - ✅ Server Members Intent
     - ✅ Message Content Intent
   - Click "Reset Token" and copy the new bot token
   - Save the token securely (you'll need it for setup)

2. **Discord Server Setup**
   - Create two channels in your Discord server:
     - `#owner` - Private planning channel (human ↔ owner agent)
     - `#team` - Public coordination channel (all agents)
   - Invite your bot to the server with these permissions:
     - Read Messages/View Channels
     - Send Messages
     - Read Message History
     - Add Reactions
     - Use Slash Commands

3. **Get Discord IDs** (Enable Developer Mode first)
   - Enable Developer Mode: `User Settings → Advanced → Developer Mode`
   - Right-click on your server name → Copy Server ID (Guild ID)
   - Right-click on your username → Copy User ID
   - Right-click on `#owner` channel → Copy Channel ID
   - Right-click on `#team` channel → Copy Channel ID

### Automated Setup

Run the interactive setup script:

```bash
make openclaw-config-setup
```

Or directly:

```bash
./scripts/setup-openclaw-config.sh
```

The script will:
1. ✅ Backup existing config (if any)
2. ✅ Prompt for Discord credentials
3. ✅ Validate input format
4. ✅ Generate secure gateway auth token
5. ✅ Create `openclaw.json` from template
6. ✅ Set proper file permissions (600)

### What You'll Be Asked For

| Field | Description | Example | How to Get |
|-------|-------------|---------|------------|
| Discord Bot Token | Your bot's authentication token | `MTQ4M...aFqM` | Discord Developer Portal → Bot → Reset Token |
| Guild ID | Your Discord server ID | `1317014410509684799` | Right-click server → Copy Server ID |
| User ID | Your Discord user ID | `967012508865032213` | Right-click your username → Copy User ID |
| Owner Channel ID | Private planning channel | `1483684870772359208` | Right-click #owner → Copy Channel ID |
| Team Channel ID | Public coordination channel | `1483721058476490823` | Right-click #team → Copy Channel ID |

### After Setup

1. **Restart OpenClaw Gateway:**
   ```bash
   make openclaw-restart
   ```

2. **Verify Configuration:**
   ```bash
   docker exec 0xthoth-gateway openclaw doctor
   ```

3. **Check Discord Connection:**
   ```bash
   docker exec 0xthoth-gateway openclaw channels status
   ```

4. **List Agents:**
   ```bash
   make agents-list
   ```

5. **Test in Discord:**
   - Go to your `#owner` channel
   - Type: `@YourBotName hello`
   - The owner agent should respond!

---

## Manual Setup (Alternative)

If you prefer to configure manually:

1. **Copy the template:**
   ```bash
   cp .openclaw/openclaw.json.template .openclaw/openclaw.json
   ```

2. **Edit the file** and replace these placeholders:
   - `<YOUR_DISCORD_BOT_TOKEN>` → Your Discord bot token
   - `<YOUR_GUILD_ID>` → Your Discord server ID
   - `<YOUR_DISCORD_USER_ID>` → Your Discord user ID
   - `<YOUR_OWNER_CHANNEL_ID>` → Your #owner channel ID
   - `<YOUR_TEAM_CHANNEL_ID>` → Your #team channel ID
   - `<GENERATE_ON_FIRST_START>` → Generate with: `openssl rand -hex 24`

3. **Set proper permissions:**
   ```bash
   chmod 600 .openclaw/openclaw.json
   ```

4. **Restart the gateway:**
   ```bash
   make openclaw-restart
   ```

---

## File Security

The setup script and `.gitignore` ensure these files are **never committed** to version control:

- ✅ `.openclaw/openclaw.json` - Main config (contains tokens)
- ✅ `.openclaw/openclaw.json.backup.*` - Timestamped backups
- ✅ `.openclaw/agents/*/sessions/` - Session data

**⚠️ WARNING:** Never commit files containing:
- Discord bot tokens
- Gateway auth tokens
- API keys
- Session data

---

## Configuration Structure

### Two-Channel Strategy

| Channel | Purpose | Agents | Mention Required? |
|---------|---------|--------|-------------------|
| `#owner` | Private planning | owner only | ❌ No (owner is default) |
| `#team` | Public coordination | all agents | ✅ Yes for sub-agents (@frontend, @backend, @qa, @tester) |

### Agent Hierarchy

```
owner (opus-4-6) - Default agent, responds everywhere
├── frontend (sonnet-4-5) - @frontend, @Frontend, @fe
├── backend (sonnet-4-5) - @backend, @Backend, @be
├── qa-lead (sonnet-4-5) - @qa, @QA, @qa-lead
└── tester (sonnet-4-5) - @tester, @Tester, @test
```

### Skills Distribution

**Shared Skills** (all agents):
- `typescript`, `github-ops`, `lb-zod-skill`, `tmux`

**Agent-Specific Skills:**
- **owner:** `code-review`, `devops`
- **frontend:** `react-expert`, `react-best-practices`, `react-performance`, `tailwind-v4-shadcn`, `sovereign-accessibility-auditor`
- **backend:** `nestjs`, `security-auditor`, `security-scanner`
- **qa-lead:** `code-review`, `security-auditor`, `testing-patterns`
- **tester:** `testing-patterns`, `e2e-testing-patterns`, `playwright`

---

## Troubleshooting

### Discord 401 Error

```
Discord: failed (401) - getMe failed (401)
```

**Solution:**
1. Bot token is invalid or expired
2. Regenerate token in Discord Developer Portal
3. Run: `make openclaw-config-setup` to update config
4. Or manually update line 169 in `openclaw.json`
5. Restart: `make openclaw-restart`

### Missing Session Directory

```
CRITICAL: Session store dir missing (~/.openclaw/agents/owner/sessions)
```

**Solution:**
```bash
docker exec 0xthoth-gateway mkdir -p /home/node/.openclaw/agents/owner/sessions
docker exec 0xthoth-gateway mkdir -p /home/node/.openclaw/agents/qa-lead/sessions
docker exec 0xthoth-gateway mkdir -p /home/node/.openclaw/agents/frontend/sessions
docker exec 0xthoth-gateway mkdir -p /home/node/.openclaw/agents/backend/sessions
docker exec 0xthoth-gateway mkdir -p /home/node/.openclaw/agents/tester/sessions
make openclaw-restart
```

### Mutable Allowlist Warning

This warning appears even when using stable Discord IDs. It's typically a false positive and can be safely ignored if you're already using numeric Discord user IDs.

### Permission Issues

```
State directory permissions are too open
```

**Solution:**
```bash
docker exec 0xthoth-gateway chmod 700 /home/node/.openclaw
docker exec 0xthoth-gateway chmod 600 /home/node/.openclaw/openclaw.json
make openclaw-restart
```

### Agent Not Responding

**Checklist:**
1. ✅ Is the gateway running? `docker ps | grep gateway`
2. ✅ Is Discord connected? `docker exec 0xthoth-gateway openclaw channels status`
3. ✅ Are you in the right channel? (#owner or #team)
4. ✅ Did you @mention the agent? (required for sub-agents in #team)
5. ✅ Is the bot online in Discord? (check member list)

---

## Advanced Configuration

### Updating Discord Token Only

If you just need to update the Discord token:

```bash
make openclaw-discord-token token="YOUR_NEW_TOKEN_HERE"
```

### Viewing Current Configuration

```bash
docker exec 0xthoth-gateway cat /home/node/.openclaw/openclaw.json | jq
```

### Resetting Configuration

To start fresh:

```bash
# Backup current config
cp .openclaw/openclaw.json .openclaw/openclaw.json.backup.manual

# Run setup again
make openclaw-config-setup

# Restart
make openclaw-restart
```

---

## Related Documentation

- **Quick Reference:** `.openclaw/CONFIG.md`
- **Architecture Diagrams:** `.openclaw/ARCHITECTURE.md`
- **Agent Workflows:** `.openclaw/workspace-*/AGENTS.md`
- **Tmux Integration:** `.openclaw/TMUX-IMPLEMENTATION.md`
- **Two-Channel Strategy:** `.openclaw/TWO-CHANNEL-SETUP.md`
- **Memory System:** `~/.claude/projects/-Users-akharawitaryakom-Documents-0xthoth-dev-ai/memory/MEMORY.md`

---

## Support

If you encounter issues:

1. **Check logs:**
   ```bash
   docker logs 0xthoth-gateway --tail 100 -f
   ```

2. **Run diagnostics:**
   ```bash
   docker exec 0xthoth-gateway openclaw doctor
   ```

3. **Verify gateway status:**
   ```bash
   make gateway-status
   ```

4. **Review this guide's troubleshooting section**

---

**Last Updated:** 2026-03-19
**Project:** `/Users/akharawitaryakom/Documents/0xthoth-dev-ai/`
