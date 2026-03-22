# Multi-Project Deployment

How to run multiple projects using separate instances of this template, sharing a single Traefik reverse proxy.

---

## Overview

Each project gets its own:
- `docker-compose.yml` and `.env`
- Discord bot and guild (server)
- Set of containers (dev-server + openclaw-gateway)
- Unique `PROJECT_NAME` for container naming and routing

All projects share:
- One Traefik instance for reverse proxy / HTTPS
- The `traefik_net` Docker network

---

## Setup

### 1. Clone Template Per Project

```bash
# Project A
git clone <template-repo> project-a
cd project-a
cp .env.example .env
# Edit .env: PROJECT_NAME=project-a, SSH_PORT=2222

# Project B
git clone <template-repo> project-b
cd project-b
cp .env.example .env
# Edit .env: PROJECT_NAME=project-b, SSH_PORT=2223
```

### 2. Port Allocation

Each project needs a unique SSH port. Suggested allocation:

| Project | PROJECT_NAME | SSH_PORT | code-server URL | OpenClaw URL |
|---------|-------------|----------|-----------------|--------------|
| Project A | `project-a` | 2222 | `project-a.code.localhost` | `project-a.openclaw.localhost` |
| Project B | `project-b` | 2223 | `project-b.code.localhost` | `project-b.openclaw.localhost` |
| Project C | `project-c` | 2224 | `project-c.code.localhost` | `project-c.openclaw.localhost` |

> **Note:** code-server and OpenClaw URLs are auto-generated from `PROJECT_NAME` via Traefik labels. Only SSH ports need manual allocation.

### 3. Discord Setup Per Project

Each project needs its own Discord bot and guild:

1. Create a new Discord server (guild) for the project
2. Create a new bot application at https://discord.com/developers
3. Create channels: `#general`, `#team`, `#fe`, `#be`, `#tt`, `#qa`
4. Invite the bot with appropriate permissions
5. Update `openclaw.json.template` with the new bot token and channel IDs

> **Why separate bots?** Each OpenClaw instance manages one bot. Sharing a bot across projects would cause routing conflicts.

### 4. Shared Traefik

Start Traefik once (it serves all projects):

```bash
# From any project directory
make traefik-start

# Or manually
docker network create traefik_net 2>/dev/null
docker run -d \
  --name traefik \
  --network traefik_net \
  -p 80:80 -p 443:443 \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  traefik:v3 \
  --providers.docker=true \
  --providers.docker.exposedbydefault=false \
  --entrypoints.web.address=:80
```

### 5. Start Each Project

```bash
# In each project directory
docker compose up -d
```

---

## Resource Considerations

Each project runs 2-3 containers:
- **dev-server:** ~512MB RAM baseline
- **openclaw-gateway:** ~256MB RAM baseline

For a machine running 3 projects: ~2-3GB RAM recommended.

### API Key Management

- Each project can share the same `ANTHROPIC_API_KEY` (usage is billed to the key)
- Each project should have its own `GITHUB_TOKEN` scoped to its repository
- Store secrets in each project's `.env` file (gitignored)

---

## Troubleshooting

### Container name conflicts
If you see "container name already in use," ensure each project has a unique `PROJECT_NAME` in `.env`.

### Port conflicts
If SSH ports conflict, change `SSH_PORT` in `.env`. Only SSH needs unique ports — HTTP routing is handled by Traefik via hostnames.

### Traefik not routing
Ensure both the project containers and Traefik are on the `traefik_net` network:
```bash
docker network inspect traefik_net
```
