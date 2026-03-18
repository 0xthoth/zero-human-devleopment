# Discord Integration Setup Guide

This guide shows you how to configure Discord integration for your OpenClaw agents.

## Prerequisites

1. ✅ Discord Bot created at https://discord.com/developers/applications
2. ✅ Bot invited to your Discord server with proper permissions
3. ✅ `.openclaw/openclaw.json` exists (run `make init` if not)

## Step 1: Get Your Discord Bot Token

1. Go to https://discord.com/developers/applications
2. Select your application
3. Go to "Bot" section
4. Click "Reset Token" and copy the new token
5. **Save it securely** - you'll need it in the next step

## Step 2: Get Discord IDs

### Get Guild (Server) ID

1. Enable Developer Mode in Discord:
   - User Settings → Advanced → Developer Mode (toggle ON)

2. Right-click your Discord server icon → "Copy Server ID"
   - Example: `131701441050968xxxx`

### Get Channel IDs

Right-click each channel you want agents in → "Copy Channel ID"

Example channel setup:
- `#owner` channel → `148368487077235xxxx`
- `#frontend` channel → `148368496542928xxxx`
- `#backend` channel → `148368509976864xxxx`
- `#qa-lead` channel → `148368521442846xxxx`
- `#tester` channel → `148368536467263xxxx`

### Get Your User ID

Right-click your username → "Copy User ID"
- Example: `96701250886503xxxx`

## Step 3: Configure openclaw.json

Edit `.openclaw/openclaw.json`:

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "YOUR_BOT_TOKEN_HERE",
      "groupPolicy": "allowlist",
      "streaming": "off",
      "guilds": {
        "YOUR_GUILD_ID_HERE": {
          "requireMention": true,
          "users": ["YOUR_USER_ID_HERE"],
          "channels": {
            "OWNER_CHANNEL_ID": { "allow": true, "requireMention": false },
            "FRONTEND_CHANNEL_ID": { "allow": true, "requireMention": false },
            "BACKEND_CHANNEL_ID": { "allow": true, "requireMention": false },
            "QA_CHANNEL_ID": { "allow": true, "requireMention": false },
            "TESTER_CHANNEL_ID": { "allow": true, "requireMention": false }
          }
        }
      }
    }
  },
  "bindings": [
    { "agentId": "owner", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "OWNER_CHANNEL_ID" } } },
    { "agentId": "frontend", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "FRONTEND_CHANNEL_ID" } } },
    { "agentId": "backend", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "BACKEND_CHANNEL_ID" } } },
    { "agentId": "qa-lead", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "QA_CHANNEL_ID" } } },
    { "agentId": "tester", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "TESTER_CHANNEL_ID" } } }
  ]
}
```

### Real Example (with placeholder values):

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "MTQxxxxx...YOUR_BOT_TOKEN_HERE...xxxxx",
      "groupPolicy": "allowlist",
      "streaming": "off",
      "guilds": {
        "131701441050968xxxx": {
          "requireMention": true,
          "users": ["96701250886503xxxx"],
          "channels": {
            "148368487077235xxxx": { "allow": true, "requireMention": false },
            "148368496542928xxxx": { "allow": true, "requireMention": false },
            "148368509976864xxxx": { "allow": true, "requireMention": false },
            "148368521442846xxxx": { "allow": true, "requireMention": false },
            "148368536467263xxxx": { "allow": true, "requireMention": false }
          }
        }
      }
    }
  },
  "bindings": [
    { "agentId": "owner", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "148368487077235xxxx" } } },
    { "agentId": "frontend", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "148368496542928xxxx" } } },
    { "agentId": "backend", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "148368509976864xxxx" } } },
    { "agentId": "qa-lead", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "148368521442846xxxx" } } },
    { "agentId": "tester", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "148368536467263xxxx" } } }
  ]
}
```

## Step 4: Understanding the Configuration

### Discord Section

```json
"discord": {
  "enabled": true,                    // Turn Discord on/off
  "token": "YOUR_TOKEN",              // Your bot token
  "groupPolicy": "allowlist",         // Only allow listed users/guilds
  "streaming": "off",                 // Streaming mode
  "guilds": { ... }                   // Server configurations
}
```

### Guild Configuration

```json
"YOUR_GUILD_ID": {
  "requireMention": true,              // Require @mention to trigger
  "users": ["USER_ID_1", "USER_ID_2"], // Allowed user IDs
  "channels": {
    "CHANNEL_ID": {
      "allow": true,                   // Allow bot in this channel
      "requireMention": false          // Don't require @mention in this channel
    }
  }
}
```

### Bindings

Bindings connect agents to specific Discord channels:

```json
"bindings": [
  {
    "agentId": "owner",                // Agent to bind
    "match": {
      "channel": "discord",            // Platform
      "peer": {
        "kind": "channel",             // Type of peer
        "id": "CHANNEL_ID"             // Specific channel ID
      }
    }
  }
]
```

## Step 5: Restart Gateway

After configuring, restart the OpenClaw gateway:

```bash
make openclaw-restart

# Or manually:
docker restart $(docker ps -q -f name=gateway)
```

## Step 6: Test It!

1. Go to one of your configured Discord channels
2. Send a message: `@YourBotName hello`
3. The appropriate agent should respond!

## Configuration Options Explained

### `requireMention`

**At guild level:**
```json
"requireMention": true  // Must @mention bot to trigger in ANY channel
```

**At channel level:**
```json
"requireMention": false  // Bot responds to all messages in this channel
```

### `groupPolicy`

- `"allowlist"` - Only listed users/guilds can interact
- `"open"` - Anyone can interact (not recommended)

### `streaming`

- `"off"` - Send complete responses at once
- `"on"` - Stream responses token by token (typing effect)

## Multiple Guilds

You can configure multiple Discord servers:

```json
"guilds": {
  "GUILD_ID_1": {
    "requireMention": true,
    "users": ["USER_1"],
    "channels": { ... }
  },
  "GUILD_ID_2": {
    "requireMention": true,
    "users": ["USER_2"],
    "channels": { ... }
  }
}
```

## Channel Binding Strategies

### Strategy 1: One Agent Per Channel (Recommended)

```json
"bindings": [
  { "agentId": "owner", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "OWNER_CHANNEL" } } },
  { "agentId": "frontend", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "FRONTEND_CHANNEL" } } }
]
```

Each agent gets its own channel. Clean and organized.

### Strategy 2: No Bindings (Mention-Based)

```json
"bindings": []
```

Don't bind agents to channels. Instead, use `@mention` patterns:
- `@owner help` → Owner agent responds
- `@frontend review` → Frontend agent responds

Works in any allowed channel.

### Strategy 3: Multiple Agents, One Channel

```json
"bindings": [
  { "agentId": "owner", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "SHARED_CHANNEL" } } },
  { "agentId": "frontend", "match": { "channel": "discord", "peer": { "kind": "channel", "id": "SHARED_CHANNEL" } } }
]
```

Multiple agents monitoring the same channel. They respond based on `@mentions`.

## Troubleshooting

### Bot doesn't respond

1. **Check bot is online**: Look for green status in Discord
2. **Check permissions**: Bot needs "Read Messages", "Send Messages", "Read Message History"
3. **Check configuration**: Verify guild ID, channel IDs, user ID are correct
4. **Check logs**: `docker logs <project>-gateway`
5. **Restart gateway**: `make openclaw-restart`

### "Permission denied" errors

Bot needs these Discord permissions:
- ✅ View Channels
- ✅ Send Messages
- ✅ Read Message History
- ✅ Embed Links
- ✅ Attach Files
- ✅ Use External Emojis (optional)

### Bot responds in wrong channel

Check your `bindings` configuration. Each binding connects an agent to a specific channel.

### Multiple agents respond

If `bindings` are empty and multiple agents have matching `mentionPatterns`, they might both respond. Use specific bindings to prevent this.

## Security Best Practices

1. ✅ **Never commit Discord tokens** - They're in `.openclaw/openclaw.json` which is gitignored
2. ✅ **Use allowlist** - Set `"groupPolicy": "allowlist"` and list specific users
3. ✅ **Regenerate tokens** - If token is leaked, regenerate it immediately at Discord Developer Portal
4. ✅ **Restrict bot permissions** - Only give necessary Discord permissions
5. ✅ **Use private channels** - Put agents in private channels, not public ones

## Advanced: Using OpenClaw CLI

Configure Discord via OpenClaw CLI:

```bash
# Set Discord token
docker exec <project>-gateway openclaw config set channels.discord.token '"YOUR_TOKEN"' --json

# Enable Discord
docker exec <project>-gateway openclaw config set channels.discord.enabled true --json

# Add guild
docker exec <project>-gateway openclaw config set 'channels.discord.guilds["GUILD_ID"]' '{"requireMention":true,"users":["USER_ID"]}' --json

# Restart to apply
make openclaw-restart
```

## Example Discord Server Layout

Recommended channel structure:

```
📁 AI DEV TEAM
  #owner          ← Owner agent (Opus 4.6)
  #qa-lead        ← QA Lead agent
  #frontend       ← Frontend Dev agent
  #backend        ← Backend Dev agent
  #tester         ← Tester agent
  #general        ← No agent binding, use @mentions
```

## Need Help?

- OpenClaw docs: https://github.com/openclaw/openclaw
- Discord Developer Portal: https://discord.com/developers
- Template docs: `docs/TEMPLATE.md`

---

**Remember**: Your Discord configuration stays in `.openclaw/openclaw.json` (local, gitignored). The template stays clean! 🔒
