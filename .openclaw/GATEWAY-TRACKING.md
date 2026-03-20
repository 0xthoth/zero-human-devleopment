# Gateway Activity Tracking

Track agent decision-making, conversations, and tool usage at the Gateway level.

## 🎯 Overview

The Gateway is where agents **think** and **plan**. This is different from the dev-server where agents **execute** commands. Gateway tracking shows:

- What the agent receives (user messages, tool results)
- What the agent decides to do (use Bash, Edit, Read tools)
- Full conversation context and reasoning
- All AI model interactions

## 📋 Quick Commands

### View live gateway logs
```bash
make gateway-logs
```

### View last 50 lines
```bash
make gateway-logs-tail
```

### List all agent session logs
```bash
make agent-sessions
```

### View latest session for an agent
```bash
make agent-session-view agent=owner
make agent-session-view agent=frontend
make agent-session-view agent=backend
make agent-session-view agent=qa
make agent-session-view agent=tester
```

### Watch both gateway + dev-server (split screen)
```bash
make agent-watch-all agent=frontend
```
Press `Ctrl+B` then `D` to detach from tmux split view.

---

## 🔍 Two Levels of Tracking

```
┌──────────────────────────────────────────────────────┐
│ GATEWAY (Agent Brain) 🧠                             │
│                                                      │
│ Track with:                                          │
│ - make gateway-logs                                  │
│ - make agent-sessions                                │
│ - make agent-session-view agent=X                    │
│                                                      │
│ Shows:                                               │
│ - Agent receives: "@frontend build the app"          │
│ - Agent thinks: "I need to run npm run build"        │
│ - Agent decides: Use Bash tool with SSH command      │
│ - Agent formulates: ssh dev@dev-server "..."         │
│ - Full conversation history                          │
└──────────────────────────────────────────────────────┘
           ↓ SSH Command Execution
┌──────────────────────────────────────────────────────┐
│ DEV-SERVER (Execution) ⚙️                             │
│                                                      │
│ Track with:                                          │
│ - make tmux-watch agent=X                            │
│ - make tmux-list                                     │
│                                                      │
│ Shows:                                               │
│ - Actual command: npm run build                      │
│ - Build output and logs                              │
│ - Test results                                       │
│ - Compilation errors                                 │
└──────────────────────────────────────────────────────┘
```

---

## 📂 Session Logs (`.jsonl` files)

### Where are they?

Inside the gateway container:
```
/home/node/.openclaw/agents/<agent-name>/sessions/<timestamp>.jsonl
```

### What's inside?

Each line is a JSON object representing:
- User messages
- Assistant responses
- Tool uses (Bash, Edit, Read, etc.)
- Tool results
- Timestamps

### View session contents

```bash
# List all sessions
make agent-sessions

# View latest session for an agent
make agent-session-view agent=frontend

# View specific session (inside container)
docker exec 0xthoth-gateway cat /home/node/.openclaw/agents/frontend/sessions/20260320_143022.jsonl | jq
```

---

## 🎓 Understanding Gateway Logs

### Example: Frontend builds the app

**You ask:** `@frontend build the app`

**Gateway log shows:**
```json
{
  "type": "message",
  "role": "user",
  "content": "@frontend build the app"
}

{
  "type": "message",
  "role": "assistant",
  "content": [
    {
      "type": "text",
      "text": "I'll build the app using npm"
    },
    {
      "type": "tool_use",
      "name": "Bash",
      "input": {
        "command": "ssh dev@dev-server \"cd /home/dev/projects && npm run build\""
      }
    }
  ]
}

{
  "type": "tool_result",
  "content": "Build successful! ✓"
}
```

**Dev-server tmux shows:**
```
$ npm run build
> vite build
✓ built in 2.5s
```

---

## 🔄 Typical Workflows

### 1. Debug why an agent made a decision

```bash
# See the agent's full conversation
make agent-session-view agent=frontend

# Look for the user request and the agent's response
# You'll see what tools it chose and why
```

### 2. Monitor agent in real-time (thinking + execution)

```bash
# Split screen: Gateway (left) + Dev-server (right)
make agent-watch-all agent=backend

# Left side: See agent thinking and planning
# Right side: See commands actually running
```

### 3. Review what happened in a session

```bash
# List all sessions
make agent-sessions

# Example output:
# 📄 frontend: 20260320_143022 (47 messages)
# 📄 backend: 20260320_144511 (23 messages)
# 📄 owner: 20260320_150033 (156 messages)

# View the session you care about
make agent-session-view agent=owner
```

### 4. Track a specific agent's activity

```bash
# Follow gateway logs filtered by agent
docker logs -f 0xthoth-gateway 2>&1 | grep -i "frontend"

# Or use the all-in-one command
make agent-watch-all agent=frontend
```

---

## 🛠️ Advanced Usage

### Manual session inspection (inside container)

```bash
# List all agent session directories
docker exec 0xthoth-gateway ls -la /home/node/.openclaw/agents/

# Find all session files
docker exec 0xthoth-gateway find /home/node/.openclaw/agents -name "*.jsonl"

# View session with jq for pretty formatting
docker exec 0xthoth-gateway cat /home/node/.openclaw/agents/frontend/sessions/latest.jsonl | jq

# Count messages in a session
docker exec 0xthoth-gateway wc -l /home/node/.openclaw/agents/frontend/sessions/latest.jsonl

# Extract only user messages
docker exec 0xthoth-gateway jq 'select(.role=="user") | .content' /home/node/.openclaw/agents/frontend/sessions/latest.jsonl
```

### Filter logs by type

```bash
# Show only tool uses
make agent-session-view agent=frontend | grep "tool_use"

# Show only errors
make gateway-logs | grep -i "error"

# Show specific agent activity
make gateway-logs | grep "@backend"
```

---

## 🔎 What to Look For

### Agent received your message?
```bash
make agent-session-view agent=frontend
# Look for: "role": "user" with your message
```

### What tools did the agent use?
```bash
make agent-session-view agent=frontend
# Look for: "type": "tool_use", "name": "Bash"|"Edit"|"Read"
```

### Did the tool succeed?
```bash
make agent-session-view agent=frontend
# Look for: "type": "tool_result" after each tool_use
```

### Full conversation flow?
```bash
make agent-session-view agent=frontend
# Read the entire session from top to bottom
```

---

## 📊 Comparison: Gateway vs Dev-Server

| Aspect | Gateway Tracking | Dev-Server Tracking |
|--------|------------------|---------------------|
| **What it shows** | Agent thinking/planning | Command execution |
| **Commands** | `make gateway-logs`<br>`make agent-sessions` | `make tmux-watch`<br>`make tmux-list` |
| **Data format** | JSON logs (`.jsonl`) | Terminal output |
| **Use when** | Understanding decisions<br>Debugging AI behavior | Watching builds/tests<br>Seeing command results |
| **Location** | Gateway container | Dev-server container |
| **Persistence** | Permanent session files | Tmux session (until restart) |

---

## 🎉 Benefits

✅ **Complete visibility** - See both thinking AND execution
✅ **Debug AI decisions** - Understand why agents chose specific actions
✅ **Review conversations** - Full context preserved in session logs
✅ **Track tool usage** - See every Bash, Edit, Read call
✅ **Troubleshoot errors** - Find where things went wrong
✅ **Learn AI behavior** - Study how agents solve problems

---

## 🚀 Try It Now!

### Watch an agent work (both levels)

1. **Start split monitoring:**
   ```bash
   make agent-watch-all agent=frontend
   ```

2. **In Discord, ask the agent to do something:**
   ```
   @frontend run the linter
   ```

3. **Observe:**
   - **Left side (Gateway):** Agent receives message, decides to use Bash tool
   - **Right side (Dev-server):** Actual `npm run lint` command executes

4. **Detach:** Press `Ctrl+B` then `D`

### Review session history

```bash
# See all sessions
make agent-sessions

# View what the owner agent did
make agent-session-view agent=owner
```

---

## 📚 Related Documentation

- **[AGENT-TMUX-TRACKING.md](AGENT-TMUX-TRACKING.md)** - Dev-server command execution tracking
- **Gateway only** - This file (current)
- **Both levels** - Use `make agent-watch-all agent=X`

---

## 💡 Pro Tips

1. **Use split view by default** - See both thinking and execution simultaneously
2. **Check sessions after errors** - Session logs show the full context of what went wrong
3. **Filter gateway logs** - Use `grep` to focus on specific agents or errors
4. **Compare timestamps** - Gateway timestamps match tool execution in dev-server
5. **Save important sessions** - Copy `.jsonl` files for later analysis

---

## 🐛 Troubleshooting

### No sessions found for agent?

Agent hasn't been used yet. Send a message to the agent in Discord first.

### Gateway logs not showing anything?

Gateway might not be running. Check: `docker ps | grep gateway`

### Session file is huge?

Long conversations create large files. Use `tail` to see recent activity:
```bash
docker exec 0xthoth-gateway tail -100 /home/node/.openclaw/agents/owner/sessions/latest.jsonl
```

### Can't parse JSON?

Use `jq` for formatting:
```bash
docker exec 0xthoth-gateway cat session.jsonl | jq
```

---

**Remember:** Gateway = Brain 🧠 | Dev-Server = Hands ⚙️

Track both for complete visibility! 👀
