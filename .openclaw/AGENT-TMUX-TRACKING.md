# Agent Tmux Tracking (Dev-Server Level)

Track all agent command execution in real-time using tmux sessions.

## 🎯 Overview

Each OpenClaw agent has a dedicated tmux session in the dev-server where they execute commands. You can watch agents work in real-time and review their command history.

> **Note:** This tracks **command execution** only. To see agent **thinking and decision-making**, see [GATEWAY-TRACKING.md](GATEWAY-TRACKING.md).

## 📋 Quick Commands

### Setup (Run once when starting)
```bash
make tmux-setup
```

### Watch an agent in real-time
```bash
make tmux-watch agent=frontend   # Watch frontend agent
make tmux-watch agent=backend    # Watch backend agent
make tmux-watch agent=qa         # Watch QA agent
make tmux-watch agent=tester     # Watch tester agent
make tmux-watch agent=owner      # Watch owner agent
```

**To detach:** Press `Ctrl+B` then `D`

### List all sessions
```bash
make tmux-list
```

### Kill all agent sessions
```bash
make tmux-kill
```

---

## 🔍 How It Works

### Agent Sessions

| Agent | Tmux Session | What to watch |
|-------|--------------|---------------|
| Frontend | `agent-frontend` | React builds, tests, lint |
| Backend | `agent-backend` | API tests, DB migrations |
| QA Lead | `agent-qa` | Test execution, coverage |
| Tester | `agent-tester` | E2E tests, integration tests |
| Owner | `agent-owner` | Git operations, coordination |

### What Agents Do in Tmux

When an agent executes a command, it runs in their tmux session:

```bash
# Agent executes this:
ssh dev@dev-server "tmux send-keys -t agent-frontend 'npm run build' Enter"

# You can watch it happen:
make tmux-watch agent=frontend
```

---

## 📊 Tracking Agent Activity

### Real-time Monitoring

1. **Open a terminal window**
2. **Run:** `make tmux-watch agent=frontend`
3. **Watch the agent work** - you'll see all commands they execute
4. **Detach when done:** Press `Ctrl+B` then `D`

### Practical Examples

**Example 1: Watch a build**
```bash
# Terminal 1: Start monitoring
make tmux-watch agent=frontend

# Discord: Ask agent to build
@frontend build the production app

# You'll see in Terminal 1:
# $ npm run build
# > vite build
# ✓ 156 modules transformed
# ✓ built in 2.3s
```

**Example 2: Monitor test execution**
```bash
# Start watching backend agent
make tmux-watch agent=backend

# Ask agent to run tests
@backend run the API tests

# You'll see live test output:
# $ npm test
# PASS src/auth/auth.service.spec.ts
# ✓ should be defined
# ✓ should return token for valid credentials
```

**Example 3: Check what went wrong**
```bash
# Agent reported an error, check what happened
make tmux-watch agent=qa

# Once attached, scroll up to see history
# Press: Ctrl+B then [
# Scroll up with Page Up
# Find the error message
# Press 'q' to exit scroll mode
```

### Review Command History

Each tmux session maintains scrollback buffer with command history.

**Option 1: Attach and scroll (recommended)**
```bash
# Attach to agent's session
make tmux-watch agent=frontend

# Once inside, enter scroll mode
# Press: Ctrl+B then [
# Use arrow keys or Page Up/Down to scroll
# Press 'q' to exit scroll mode
```

**Option 2: Manual access (inside dev-server)**
```bash
# SSH into dev-server
make ssh

# List all tmux sessions
tmux ls

# Attach to a specific session
tmux attach -t agent-frontend

# Detach: Ctrl+B then D
```

---

## 🎓 Understanding the Workflow

### Before (No Tmux)
```
You: "@frontend build the app"
Frontend Agent: *runs commands invisibly*
You: "What did it do? 🤷"
```

### After (With Tmux)
```
You: "@frontend build the app"
You: *opens terminal: make tmux-watch agent=frontend*
You: *watches every command execute in real-time*
You: "Ah, I see exactly what it's doing! 👀"
```

---

## 🛠️ Advanced Usage

### Manual tmux commands (via Docker)

```bash
# List sessions (from host)
docker compose exec -u dev dev-server tmux ls

# Attach to a session (from host)
docker compose exec -u dev dev-server tmux attach -t agent-frontend

# OR: SSH into dev-server first
make ssh

# Then use tmux commands directly
tmux ls
tmux attach -t agent-frontend
tmux new-window -t agent-frontend
tmux split-window -t agent-frontend
```

### Tmux keyboard shortcuts

| Action | Shortcut | Description |
|--------|----------|-------------|
| Detach from session | `Ctrl+B` then `D` | Exit without stopping session |
| Scroll mode (history) | `Ctrl+B` then `[` | View command history/output |
| Exit scroll mode | `q` | Return to live view |
| List sessions | `Ctrl+B` then `S` | Switch between sessions |
| Next window | `Ctrl+B` then `N` | Move to next window |
| Previous window | `Ctrl+B` then `P` | Move to previous window |
| Split horizontal | `Ctrl+B` then `"` | Split pane horizontally |
| Split vertical | `Ctrl+B` then `%` | Split pane vertically |
| Switch panes | `Ctrl+B` then arrows | Navigate between panes |

**Scroll mode tips:**
- Use arrow keys or Page Up/Down to navigate
- Press `/` to search forward, `?` to search backward
- Press `g` to jump to top, `G` to jump to bottom

---

## 🔄 Setup & Lifecycle

### Initial Setup

The tmux sessions are created automatically when you run:
```bash
make tmux-setup
```

This command:
1. Creates logs directory: `/home/dev/logs`
2. Creates 5 tmux sessions: `agent-frontend`, `agent-backend`, `agent-qa`, `agent-tester`, `agent-owner`
3. Each session has one window named "work"

### Session Lifecycle

Sessions persist until:
- **You kill them manually:** `make tmux-kill`
- **Dev-server container restarts:** Requires running `make tmux-setup` again
- **Docker compose restarts:** Requires running `make tmux-setup` again

### Best Practices

**✅ DO:**
- Run `make tmux-setup` after starting containers
- Keep sessions running during development
- Detach (`Ctrl+B` then `D`) instead of exiting
- Use scroll mode to review history

**❌ DON'T:**
- Exit tmux sessions with `exit` command (kills the session)
- Kill sessions unless resetting
- Create duplicate sessions manually

**Tip:** Add this to your startup script:
```bash
#!/bin/bash
make start          # Start containers
sleep 5             # Wait for containers
make tmux-setup     # Setup agent sessions
```

---

## 📝 Persistent Logging (Optional)

You can optionally enable persistent logging to capture all tmux output to files:

### Enable logging for a session

```bash
# SSH into dev-server
make ssh

# Enable logging for frontend agent
tmux pipe-pane -t agent-frontend -o "cat >> /home/dev/logs/agent-frontend.log"

# Enable for all agents
for agent in frontend backend qa tester owner; do
  tmux pipe-pane -t agent-$agent -o "cat >> /home/dev/logs/agent-$agent.log"
done
```

### View logs

```bash
# From host machine
docker compose exec dev-server tail -f /home/dev/logs/agent-frontend.log

# Or inside dev-server
make ssh
tail -f /home/dev/logs/agent-frontend.log
```

### Disable logging

```bash
# SSH into dev-server
make ssh

# Disable for specific agent
tmux pipe-pane -t agent-frontend -o ""
```

**Note:** Logs persist across tmux detach/attach but are lost when the container restarts.

---

## 🧠 Gateway vs Dev-Server Tracking

### Two Levels of Agent Activity

```
┌──────────────────────────────────────────────────────┐
│ GATEWAY (Agent Brain) 🧠                             │
│                                                      │
│ What agents THINK and DECIDE                         │
│                                                      │
│ Track with:                                          │
│ - make gateway-logs                                  │
│ - make agent-sessions                                │
│ - make agent-session-view agent=X                    │
│                                                      │
│ See: Full conversations, tool decisions, reasoning   │
│                                                      │
│ → Read more: .openclaw/GATEWAY-TRACKING.md           │
└──────────────────────────────────────────────────────┘
           ↓ SSH Command
┌──────────────────────────────────────────────────────┐
│ DEV-SERVER (Execution) ⚙️                             │
│                                                      │
│ What agents EXECUTE and RESULTS                      │
│                                                      │
│ Track with:                                          │
│ - make tmux-watch agent=X  ← YOU ARE HERE            │
│ - make tmux-list                                     │
│                                                      │
│ See: Command output, build results, test logs        │
│                                                      │
│ → Read more: This file (AGENT-TMUX-TRACKING.md)      │
└──────────────────────────────────────────────────────┘
```

### Watch Both Levels Simultaneously

```bash
# Split screen: Gateway (left) + Dev-server (right)
make agent-watch-all agent=frontend
```

This gives you **complete visibility**:
- **Left side:** See agent thinking, planning, deciding what to do
- **Right side:** See actual commands executing and their output

**Example workflow:**
1. Ask: `@frontend build the app`
2. Gateway shows: Agent receives message → decides to use Bash tool → formulates SSH command
3. Dev-server shows: `npm run build` executes → build output → results

---

## 🎉 Benefits

✅ **Transparency** - See exactly what commands agents execute
✅ **Debugging** - Catch errors and issues in real-time
✅ **Learning** - Understand how agents solve problems
✅ **History** - Review command history anytime
✅ **Monitoring** - Track progress on long-running tasks

> **For complete visibility:** Combine with [Gateway Tracking](GATEWAY-TRACKING.md) to see both thinking AND execution!

---

## 🐛 Troubleshooting

### "No tmux sessions running"

**Cause:** Sessions haven't been created or dev-server restarted.

**Fix:** Run `make tmux-setup`

### "Session not found: agent-frontend"

**Cause:** Agent name typo or session doesn't exist.

**Fix:**
- Check available sessions: `make tmux-list`
- Ensure correct agent name: `frontend`, `backend`, `qa`, `tester`, or `owner`

### "Can't see command output"

**Cause:** Command output scrolled off screen.

**Fix:**
- Enter scroll mode: `Ctrl+B` then `[`
- Scroll up with arrow keys or Page Up
- Exit scroll mode: Press `q`

### "Session keeps detaching"

**Cause:** Docker container connection issue.

**Fix:**
- Check container is running: `docker ps | grep dev-server`
- Try reattaching: `make tmux-watch agent=frontend`

### "Want to clear the terminal"

**While attached to tmux session:**
- Press `Ctrl+L` to clear screen
- Or type `clear` and press Enter

---

## 📚 Related Documentation

- **[COMPLETE-TRACKING-GUIDE.md](COMPLETE-TRACKING-GUIDE.md)** - Complete tracking system guide
- **[GATEWAY-TRACKING.md](GATEWAY-TRACKING.md)** - Gateway-level tracking (agent thinking)

---

## 📖 Quick Reference

### Essential Commands

| Command | Description |
|---------|-------------|
| `make tmux-setup` | Create all agent sessions (run once) |
| `make tmux-list` | List all active sessions |
| `make tmux-watch agent=X` | Attach to agent's terminal |
| `make tmux-kill` | Kill all agent sessions |
| `make agent-watch-all agent=X` | Split view: Gateway + Terminal |

### Keyboard Shortcuts (When Attached)

| Keys | Action |
|------|--------|
| `Ctrl+B` then `D` | Detach (keep session running) |
| `Ctrl+B` then `[` | Enter scroll mode (view history) |
| `q` | Exit scroll mode |
| `Ctrl+L` | Clear screen |
| `Ctrl+C` | Stop running command |

### Agent Names

| Agent | Session Name | Use For |
|-------|--------------|---------|
| Frontend | `agent-frontend` | React builds, UI work |
| Backend | `agent-backend` | API, tests, database |
| QA Lead | `agent-qa` | Code review, quality checks |
| Tester | `agent-tester` | E2E tests, integration tests |
| Owner | `agent-owner` | Git, coordination, planning |

---

## 🚀 Try It Now!

1. **Setup sessions:** `make tmux-setup`
2. **Ask an agent to do something:** "@frontend run the linter"
3. **Watch it happen:** `make tmux-watch agent=frontend`
4. **View history:** Press `Ctrl+B` then `[` to scroll through output
5. **Detach:** Press `Ctrl+B` then `D`
6. **Be amazed!** 🎭

---

## 💡 Pro Tips

1. **Always detach, never exit** - Use `Ctrl+B` then `D` instead of `exit`
2. **Use scroll mode for debugging** - `Ctrl+B` then `[` to review errors
3. **Watch builds in real-time** - Attach before asking agent to build
4. **Compare agent outputs** - Open multiple terminals, watch different agents
5. **Check sessions after errors** - Scroll up to see full error context
6. **Use split view for complete visibility** - `make agent-watch-all agent=frontend`

---

**Remember:** This is the **execution layer**. For agent **thinking and decisions**, use [Gateway Tracking](GATEWAY-TRACKING.md)! 🧠⚙️

