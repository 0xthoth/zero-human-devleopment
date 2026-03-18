# openclaw.json.template - Explanation

## What is this file?

`.openclaw/openclaw.json.template` is a **clean, safe version** of your OpenClaw configuration with all secrets removed.

## Key Differences

### ❌ openclaw.json (GITIGNORED - Has Secrets)
```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "MTQxxxxx...YOUR_BOT_TOKEN...xxxxx",
      "guilds": {
        "131701441050968xxxx": {
          "users": ["96701250886503xxxx"],
          "channels": {
            "148368487077235xxxx": { "allow": true }
          }
        }
      }
    }
  },
  "gateway": {
    "auth": {
      "token": "<GENERATE_ON_FIRST_START>"
    }
  }
}
```

### ✅ openclaw.json.template (SAFE - In Git)
```json
{
  "channels": {
    "discord": {
      "enabled": false,
      "token": "<DISCORD_BOT_TOKEN>",
      "guilds": {}
    }
  },
  "gateway": {
    "auth": {
      "token": "<GENERATE_ON_FIRST_START>"
    }
  },
  "bindings": []
}
```

## How The Template System Works

```
┌─────────────────────────────────────────┐
│  GITHUB REPOSITORY                      │
│  (Public/Shareable)                     │
│                                         │
│  ✅ openclaw.json.template              │
│     - Clean config                      │
│     - Placeholder values                │
│     - No secrets                        │
│                                         │
│  ✅ make init                    │
│     - Setup script                      │
│                                         │
│  ❌ openclaw.json                       │
│     - GITIGNORED                        │
│     - Never committed                   │
└─────────────────────────────────────────┘
                    ↓
            User clones repo
                    ↓
┌─────────────────────────────────────────┐
│  LOCAL MACHINE                          │
│  (User's private instance)              │
│                                         │
│  1. Run: make template-init             │
│     or: make init              │
│                                         │
│  2. Script copies:                      │
│     template → openclaw.json            │
│                                         │
│  3. User adds their secrets:            │
│     - Discord bot token                 │
│     - Configure channels                │
│                                         │
│  4. openclaw.json stays LOCAL           │
│     (gitignored, never pushed)          │
└─────────────────────────────────────────┘
```

## When to Use Each File

### Use `openclaw.json.template` when:
- ✅ Updating the base configuration for all future projects
- ✅ Adding new agents to the template
- ✅ Changing default settings
- ✅ Committing changes to Git

### Use `openclaw.json` when:
- ✅ Running your actual project
- ✅ Adding Discord tokens
- ✅ Configuring channel bindings
- ✅ Updating gateway settings
- ❌ NEVER commit this file!

## How Users Initialize New Projects

### Option 1: Using make init (Recommended)

```bash
make init
# Prompts for project details
# Creates .env with secrets
# Ready to start!
```

### Option 2: Manual Setup

```bash
# 1. Copy template to active config
cp .openclaw/openclaw.json.template .openclaw/openclaw.json

# 2. Edit openclaw.json manually
nano .openclaw/openclaw.json

# 3. Add your Discord bot token
# Replace: "<DISCORD_BOT_TOKEN>"
# With: "MTQxxxxx...YOUR_BOT_TOKEN...xxxxx"

# 4. Enable Discord
# Change: "enabled": false
# To: "enabled": true

# 5. Add guild configuration
# Add your guild ID, channels, etc.
```

## Example: Adding a New Agent to Template

When you want to add a new agent that ALL future projects should have:

```bash
# 1. Edit the TEMPLATE file
nano .openclaw/openclaw.json.template

# 2. Add the agent to "agents.list"
{
  "id": "devops",
  "name": "DevOps Engineer",
  "workspace": "/home/node/.openclaw/workspace-devops",
  "agentDir": "/home/node/.openclaw/agents/devops/agent",
  "model": "anthropic/claude-sonnet-4-5",
  "groupChat": {
    "mentionPatterns": ["@devops", "@DevOps"]
  }
}

# 3. Commit the template
git add .openclaw/openclaw.json.template
git commit -m "Add DevOps agent to template"
git push

# 4. Your local openclaw.json can be updated separately
# (or regenerated from template)
```

## Security Benefits

### Without Template System (BAD)
```
openclaw.json (has secrets) → Git → GitHub → 💥 LEAKED!
```

### With Template System (GOOD)
```
openclaw.json.template (clean) → Git → GitHub → ✅ Safe
openclaw.json (secrets) → GITIGNORED → ✅ Stays local
```

## Commands for Template Management

```bash
# Reset to template (WARNING: Deletes local config!)
make template-reset

# Initialize from template
make template-init

# Verify no secrets in git
./verify-template.sh

# Check what will be committed
git status
```

## FAQ

### Q: I modified openclaw.json, will it be committed?
**A:** No! It's gitignored. Only `openclaw.json.template` gets committed.

### Q: I want to change the default agent configuration. Which file?
**A:** Edit `openclaw.json.template` and commit it. Future users get the update.

### Q: I added Discord channels. Which file has them?
**A:** Your local `openclaw.json`. That's your private configuration.

### Q: Can I manually sync template changes to my local config?
**A:** Yes! Compare the files:
```bash
# See differences
diff .openclaw/openclaw.json.template .openclaw/openclaw.json

# Or manually merge changes
# Copy agent configs from template, keep your secrets
```

### Q: I cloned the template but openclaw.json doesn't exist!
**A:** Expected! Run `make init` or manually copy:
```bash
cp .openclaw/openclaw.json.template .openclaw/openclaw.json
```

### Q: How do I update my template when OpenClaw releases new features?
**A:** Pull changes from the template repository:
```bash
git remote add template https://github.com/your/template-repo
git fetch template
git merge template/main
```
Review `openclaw.json.template` for updates, then merge them into your local `openclaw.json`.

## Summary

| File | Purpose | Contains Secrets? | In Git? | Who Uses? |
|------|---------|------------------|---------|-----------|
| `openclaw.json.template` | Base config | ❌ No | ✅ Yes | Everyone cloning |
| `openclaw.json` | Active config | ✅ Yes | ❌ No | Your local instance |
| `.env` | API keys | ✅ Yes | ❌ No | Your local instance |
| `.env.example` | Env template | ❌ No | ✅ Yes | Documentation |

**Key Rule**:
- Template files = Safe to share
- Actual config files = Local only, gitignored

---

**Need Help?** See `docs/READY-TO-PUSH.md` for security verification.
