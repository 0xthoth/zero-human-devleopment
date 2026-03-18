# Setup Guide

Step-by-step from zero to agents ready.

## Prerequisites

- Docker + Docker Compose v2
- GitHub CLI (`gh`) authenticated
- Anthropic API key
- (Optional) ClawHub account for skills
- (Optional) Discord bot token (for chatting via Discord)

---

## Step 1: Configure `.env`

```bash
cp .env.example .env
```

Edit `.env`:

```bash
PROJECT_NAME=myproject
SSH_PORT=2222
DEV_USER=dev
DEV_USER_PASSWORD=<pick-a-strong-password>
GIT_USER_NAME=openclaw-5-agent-template
GIT_USER_EMAIL=bot@myorg.dev
ANTHROPIC_API_KEY=sk-ant-xxxx
GITHUB_TOKEN=ghp_xxxx
```

---

## Step 2: Start Traefik (once, shared across all projects)

```bash
make traefik-start
```

Verify: open http://traefik.localhost

---

## Step 3: Build & Start

```bash
make build          # builds dev-server image (~5 min first time)
make start          # starts dev-server + openclaw-gateway
```

---

## Step 4: Install Linux dependencies

macOS native binaries won't work in the Linux container. Run once:

```bash
make dev-install
```

Run again whenever you add/change npm dependencies.

---

## Step 5: Approve browser device

Open http://${PROJECT_NAME}.openclaw.localhost — you'll see "pairing required".

In another terminal:

```bash
make openclaw-devices-list
```

Find the pending request ID, then:

```bash
make openclaw-devices-approve requestId=<the-request-id>
```

Refresh the browser — you're in.

---

## Step 6: Login to ClawHub (for skills)

```bash
docker exec -it ${PROJECT_NAME}-gateway npx clawhub login
```

It shows a URL with a token like:

```
http://127.0.0.1:XXXXX/callback#token=clh_xxxxx...
```

The browser can't reach this inside Docker. Extract the token from the URL and run:

```bash
docker exec ${PROJECT_NAME}-gateway npx clawhub login --token clh_xxxxx...
```

---

## Step 7: Install skills

```bash
make install-skills
```

Installs 16+ skills (github-ops, react-expert, nestjs, security-auditor, etc.). Skills flagged as suspicious are skipped — force with `--force` if needed.

---

## Step 8: Create GitHub repo

```bash
git init
git add .
git commit -m "initial: openclaw 5-agent dev team"
gh repo create openclaw-5-agent-template --private --source=. --push
```

Agents need a GitHub repo for branches and PRs.

---

## Step 9: Verify SSH (gateway → dev-server)

```bash
docker exec ${PROJECT_NAME}-gateway ssh dev@dev-server "echo OK"
```

If SSH client is missing in the gateway image:

```bash
docker exec ${PROJECT_NAME}-gateway apk add --no-cache openssh-client 2>/dev/null || \
docker exec ${PROJECT_NAME}-gateway apt-get install -y openssh-client 2>/dev/null
```

---

## Step 10: Connect Discord (optional)

Create a Discord bot at https://discord.com/developers/applications:

1. New Application → Bot → Reset Token → copy token
2. Bot settings: enable **Message Content Intent**
3. Invite bot to your server with `bot` + `applications.commands` scopes

Set the token:

```bash
make openclaw-discord-token token=YOUR_DISCORD_BOT_TOKEN
```

This updates `openclaw.json` and restarts the gateway automatically.

---

## Step 11: Start chatting

**Web UI:** Open http://${PROJECT_NAME}.openclaw.localhost

**Discord:** Message in your Discord server

Type:

> Hello @owner, are you ready?

Then assign a real task:

> I want a user authentication system with login and register

---

## Access Points

| Access | Protocol | How |
|--------|----------|-----|
| Code-server (IDE) | HTTP | http://${PROJECT_NAME}.code.localhost (via Traefik :80) |
| OpenClaw Web UI | HTTP | http://${PROJECT_NAME}.openclaw.localhost (via Traefik :80) |
| Traefik Dashboard | HTTP | http://traefik.localhost |
| Discord | Bot | Add bot to your Discord server |
| SSH to dev-server | TCP | `ssh dev-server-local` or `ssh -p 2222 dev@localhost` (direct, not via Traefik) |

Password for code-server and SSH: whatever you set in `DEV_USER_PASSWORD`.

### SSH shortcut (recommended)

Add this to your `~/.ssh/config` to avoid host key warnings after every rebuild:

```
Host dev-server-local
    HostName localhost
    Port 2222
    User dev
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

Then just: `ssh dev-server-local`

### tmux

A tmux session named `dev` auto-starts when the dev-server boots. After SSH:

```bash
tmux attach -t dev    # attach to the auto-started session
```

---

---

## Volume Mounts (Optimization)

The template uses optimized volume mounts for better security and performance:

| Container | Mounts | Why |
|-----------|--------|-----|
| **openclaw-gateway** | Full project (`./`) | Needs to edit all files, run git operations |
| **dev-server** | Only `apps/`, `packages/`, config | Only needs code for builds/tests |

**Dev-server has access to:**
- ✅ `apps/` - Application code
- ✅ `packages/` - Shared libraries
- ✅ `package.json`, `package-lock.json` - Workspace config
- ✅ `node_modules/` - Dependencies
- ❌ `.openclaw/`, `docs/`, `build/`, `.github/` - Not needed for builds

This reduces the attack surface and file watching overhead while keeping full functionality.

---

## Troubleshooting

### `npm test` / `npm run build` fails with binary errors

```bash
make dev-install
```

### Gateway restart-looping

```bash
docker logs ${PROJECT_NAME}-gateway --tail 30
```

Common fixes:
- `gateway.mode` not set → must be `"local"` in openclaw.json
- `controlUi.allowedOrigins` missing → add `"dangerouslyAllowHostHeaderOriginFallback": true`
- Discord warnings → set `"channels": {}` if not using Discord

### `make dev-install` fails with "No such file or directory"

The command runs as root by default. Fixed in Makefile to use `-u dev` and absolute path `/home/dev/projects`.

### `git commit` "please tell me who you are"

Verify gateway has git env vars:

```bash
docker exec ${PROJECT_NAME}-gateway env | grep GIT
```

### SSH host verification blocks agents

`build/ssh-config` must be mounted with `StrictHostKeyChecking no`. Verify:

```bash
docker exec 0xthoth-gateway cat /home/node/.ssh/config
```

### Permission denied on `./data/`

```bash
make fix-data-permission
```

### ClawHub rate limited

Login first: `docker exec -it 0xthoth-gateway npx clawhub login`
Anonymous requests have very low rate limits (120/min). Authenticated gets 600/min.

### Skills install shows "suspicious" warning

Force install: add `--force` flag to the clawhub install command. These are usually false positives from documentation mentioning API keys.

### SSH "REMOTE HOST IDENTIFICATION HAS CHANGED" warning

Every `make build` creates a new container with a new SSH host key. Your Mac remembers the old key and warns you. Fix:

```bash
ssh-keygen -R "[localhost]:2222"
```

Or use the SSH shortcut config above (`StrictHostKeyChecking no`) to skip this permanently.

### Update Discord bot token

```bash
make openclaw-discord-token token=NEW_TOKEN_HERE
```

Updates the token in `openclaw.json` and restarts the gateway.

### Stale socket file crashes dev-server on rebuild

If dev-server restart-loops after rebuild with `chown: Invalid argument` on a `.sock` file, the `start.sh` auto-cleans stale sockets. If it still happens:

```bash
rm -f data/dev/.local/share/code-server/code-server-ipc.sock
docker compose up -d dev-server
```
