# Complete Agent Activity Tracking Guide

Full visibility into both agent thinking (Gateway) and command execution (Dev-Server).

## 🎯 Quick Start

```bash
# See what agents are thinking and deciding
make agent-sessions                    # List all agent conversations
make agent-session-view agent=owner    # View owner's latest session

# See what commands agents are executing
make tmux-list                        # List all running tmux sessions
make tmux-watch agent=frontend        # Watch frontend agent's terminal

# See BOTH at once (split screen)
make agent-watch-all agent=backend    # Split view: thinking + execution
```

---

## 📊 Two Levels of Tracking

### Level 1: Gateway (Agent Brain 🧠)

**What:** Agent receives messages, thinks, plans, and decides what tools to use

**Where:** Gateway container (`0xthoth-gateway`)

**Commands:**
```bash
make gateway-logs              # Live logs from gateway
make gateway-logs-tail         # Last 50 lines
make agent-sessions            # List all session files
make agent-session-view agent=X  # View latest session
```

**What you see:**
- User messages sent to agents
- Agent responses and reasoning
- Tool decisions (Bash, Edit, Read, Write)
- Full conversation context
- Timestamps and model usage

**Session files location:**
```
/home/node/.openclaw/agents/<agent-name>/sessions/<uuid>.jsonl
```

---

### Level 2: Dev-Server (Execution ⚙️)

**What:** Actual commands running and their output

**Where:** Dev-server container (via SSH tmux sessions)

**Commands:**
```bash
make tmux-setup                # Create tmux sessions (run once)
make tmux-list                 # List all sessions
make tmux-watch agent=X        # Watch agent's terminal
```

**What you see:**
- Actual commands: `npm run build`, `git status`, etc.
- Command output and errors
- Build logs, test results
- Real-time execution

**Sessions:**
```
agent-frontend   # Frontend agent's terminal
agent-backend    # Backend agent's terminal
agent-qa         # QA Lead agent's terminal
agent-tester     # Tester agent's terminal
agent-owner      # Owner agent's terminal
```

---

## 🔍 Combined Tracking Workflow

### Split Screen View (Best for Active Monitoring)

```bash
make agent-watch-all agent=frontend
```

This opens a tmux split:
- **Left side:** Gateway logs (agent thinking)
- **Right side:** Dev-server tmux (command execution)

Press `Ctrl+B` then `D` to detach.

### Example: Watch Frontend Build

1. **Start monitoring:**
   ```bash
   make agent-watch-all agent=frontend
   ```

2. **Ask agent to build (in Discord):**
   ```
   @frontend build the app
   ```

3. **Observe:**
   - **Left (Gateway):**
     - Agent receives: "@frontend build the app"
     - Agent thinks: "I need to run npm run build"
     - Agent uses: Bash tool with SSH command

   - **Right (Dev-server):**
     - Executes: `npm run build`
     - Shows: Build progress, success/errors

---

## 📋 Common Use Cases

### 1. Debug why an agent did something

**Problem:** "Why did the frontend agent restart the server?"

**Solution:**
```bash
# View the agent's conversation
make agent-session-view agent=frontend

# Look for user messages and agent responses
# You'll see the full context of what led to that decision
```

### 2. Check if a command failed

**Problem:** "Did the build succeed?"

**Solution:**
```bash
# Watch the terminal output
make tmux-watch agent=frontend

# Or check the session history
# (scroll up in the tmux session with Ctrl+B then [)
```

### 3. Monitor long-running tasks

**Problem:** "Is the backend agent still running tests?"

**Solution:**
```bash
# Watch in real-time
make tmux-watch agent=backend

# See both thinking and execution
make agent-watch-all agent=backend
```

### 4. Review what happened yesterday

**Problem:** "What did the owner agent do yesterday?"

**Solution:**
```bash
# List all sessions
make agent-sessions

# Find the session from yesterday (by timestamp in filename)
# View it directly:
docker exec 0xthoth-gateway cat /home/node/.openclaw/agents/owner/sessions/<session-id>.jsonl | jq
```

### 5. Track agent collaboration

**Problem:** "How did frontend and backend agents coordinate?"

**Solution:**
```bash
# Open two terminals
# Terminal 1:
make agent-session-view agent=frontend

# Terminal 2:
make agent-session-view agent=backend

# Compare timestamps and messages
```

---

## 🛠️ Advanced Commands

### Gateway Tracking

```bash
# Follow gateway logs filtered by agent
docker logs -f 0xthoth-gateway 2>&1 | grep -i "frontend"

# List all agents' session directories
docker exec 0xthoth-gateway ls -la /home/node/.openclaw/agents/

# View full session with pretty formatting
docker exec 0xthoth-gateway cat /home/node/.openclaw/agents/owner/sessions/<uuid>.jsonl | jq

# Count messages in a session
docker exec 0xthoth-gateway wc -l /home/node/.openclaw/agents/owner/sessions/<uuid>.jsonl

# Extract only tool uses
docker exec 0xthoth-gateway jq 'select(.message.content[]?.type=="toolCall")' /home/node/.openclaw/agents/owner/sessions/<uuid>.jsonl
```

### Dev-Server Tracking

```bash
# SSH into dev-server
make ssh

# List tmux sessions
tmux ls

# Attach to a session
tmux attach -t agent-frontend

# Detach: Ctrl+B then D

# Kill a specific session
tmux kill-session -t agent-frontend

# Kill all agent sessions
make tmux-kill

# Enable logging for a session
tmux pipe-pane -t agent-frontend "cat >> /home/dev/logs/frontend.log"
```

---

## 📚 Understanding Session Logs

### Session File Format (`.jsonl`)

Each line is a JSON object:

```json
{
  "type": "message",
  "id": "abc123",
  "timestamp": "2026-03-20T04:02:19.937Z",
  "message": {
    "role": "assistant",
    "content": [
      {
        "type": "toolCall",
        "name": "exec",
        "arguments": {
          "command": "npm run build"
        }
      }
    ]
  }
}
```

### Message Types

| Type | Description | Example |
|------|-------------|---------|
| `message` (role: user) | User sent a message | "@frontend build the app" |
| `message` (role: assistant) | Agent responds | "I'll build the app..." |
| `message` (role: toolResult) | Tool execution result | "Build succeeded" |
| `toolCall` | Agent uses a tool | Bash, Edit, Read, Write |

### Useful jq Queries

```bash
# Extract user messages only
cat session.jsonl | jq 'select(.message.role=="user") | .message.content'

# Extract tool calls only
cat session.jsonl | jq 'select(.message.content[]?.type=="toolCall")'

# Show timestamps and roles
cat session.jsonl | jq '{time: .timestamp, role: .message.role}'

# Count messages by type
cat session.jsonl | jq -r '.message.role' | sort | uniq -c
```

---

## 🎓 Comparison Table

| Aspect | Gateway Tracking | Dev-Server Tracking |
|--------|------------------|---------------------|
| **What** | Agent thinking/planning | Command execution |
| **Where** | Gateway container | Dev-server container |
| **Format** | JSON logs (`.jsonl`) | Terminal output |
| **Commands** | `make gateway-logs`<br>`make agent-sessions`<br>`make agent-session-view` | `make tmux-watch`<br>`make tmux-list`<br>`make tmux-setup` |
| **Persistence** | Permanent files | Session-based (until restart) |
| **Use for** | Understanding decisions<br>Debugging AI behavior<br>Reviewing conversations | Watching builds/tests<br>Seeing command output<br>Monitoring progress |
| **Best when** | You want to know "why" | You want to know "what happened" |

---

## 🎬 Step-by-Step Example

### Scenario: Frontend agent builds the app

1. **Start monitoring (both levels):**
   ```bash
   make agent-watch-all agent=frontend
   ```

2. **In Discord, send message:**
   ```
   @frontend build the app
   ```

3. **Observe Gateway (Left side):**
   ```
   [Gateway Log]
   Received message: @frontend build the app
   Agent: I'll run npm run build via SSH
   Tool: Bash
   Command: ssh dev@dev-server "cd /home/dev/projects && npm run build"
   ```

4. **Observe Dev-Server (Right side):**
   ```
   [Tmux Session]
   $ cd /home/dev/projects && npm run build
   > vite build
   ✓ 156 modules transformed
   ✓ built in 2.3s
   ```

5. **Review later:**
   ```bash
   # View the conversation
   make agent-session-view agent=frontend

   # You'll see the full JSON log of what happened
   ```

---

## 💡 Pro Tips

1. **Always start with split view** - See both thinking and execution simultaneously
2. **Check sessions after errors** - Full context helps understand what went wrong
3. **Use tmux scrollback** - Press `Ctrl+B` then `[` to scroll through history
4. **Filter gateway logs** - Use `grep` to focus on specific agents or keywords
5. **Save important sessions** - Copy `.jsonl` files for later analysis
6. **Compare timestamps** - Gateway logs and tmux output have matching timestamps
7. **Run tmux-setup on start** - Make it part of your daily routine

---

## 🐛 Troubleshooting

### "No sessions found for agent"

**Cause:** Agent hasn't been used yet.

**Fix:** Send a message to the agent in Discord first.

### "Gateway logs not showing anything"

**Cause:** Gateway container not running.

**Fix:** Check `docker ps | grep gateway`

### "Tmux session not found"

**Cause:** Sessions not created or dev-server restarted.

**Fix:** Run `make tmux-setup`

### "Can't attach to tmux session"

**Cause:** Already attached in another terminal.

**Fix:** Detach first (`Ctrl+B` then `D`) or use `tmux attach -d -t agent-X`

### "Session file is huge"

**Cause:** Long conversation with many messages.

**Fix:** Use `tail` or `jq` with `limit`:
```bash
docker exec 0xthoth-gateway tail -100 /home/node/.openclaw/agents/owner/sessions/<uuid>.jsonl | jq
```

---

## 📖 Related Documentation

- **[GATEWAY-TRACKING.md](GATEWAY-TRACKING.md)** - Detailed gateway tracking guide
- **[AGENT-TMUX-TRACKING.md](AGENT-TMUX-TRACKING.md)** - Detailed dev-server tracking guide
- **Makefile** - All available commands

---

## 🚀 Quick Reference

### Essential Commands

```bash
# SETUP (run once)
make tmux-setup

# GATEWAY (thinking)
make agent-sessions
make agent-session-view agent=owner

# DEV-SERVER (execution)
make tmux-list
make tmux-watch agent=frontend

# BOTH (split view)
make agent-watch-all agent=backend
```

### Keyboard Shortcuts (tmux)

| Action | Keys |
|--------|------|
| Detach from session | `Ctrl+B` then `D` |
| Scroll mode (history) | `Ctrl+B` then `[` |
| Exit scroll mode | `q` |
| Split horizontal | `Ctrl+B` then `"` |
| Split vertical | `Ctrl+B` then `%` |
| Switch panes | `Ctrl+B` then arrow keys |

---

**Remember:**

- **Gateway = Brain 🧠** - What agents think and decide
- **Dev-Server = Hands ⚙️** - What agents actually do

Track **both** for complete visibility! 👀
