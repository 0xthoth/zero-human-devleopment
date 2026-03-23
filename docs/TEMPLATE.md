# OpenClaw 5-Agent Template

🎯 **Template Project** - Clone and customize for your own projects

This is a reusable template for creating OpenClaw-based development environments with 5 AI agents: Owner, QA Lead, Frontend Dev, Backend Dev, and Tester.

## What This Template Provides

- **Pre-configured 5-agent setup** with optimized role assignments
- **Docker-based development environment** with VS Code Server
- **Multi-project support** through environment variables
- **15+ specialized skills** for TypeScript, React, NestJS, security, testing, and more
- **Clean separation** of project-specific and template configuration

## Quick Start from Template

### 1. Clone the Repository

```bash
git clone <repository-url> my-new-project
cd my-new-project
```

### 2. Initialize Your Project

Run the initialization script to set up project-specific configuration:

```bash
chmod +x make init
make init
```

You'll be prompted for:
- **Project name**: Lowercase, hyphens only (e.g., `my-awesome-project`)
- **Git user name**: Bot identity for commits (default: `<project-name>-bot`)
- **Git user email**: Bot email (default: `bot@example.com`)
- **SSH port**: Port for SSH access (default: `2222`)
- **Dev user password**: Password for the dev user inside container
- **Anthropic API key**: Your Claude API key (`sk-ant-xxxxx`)
- **GitHub token**: Optional, for GitHub operations

### 3. Start the Environment

```bash
# Start Traefik (once per machine)
make traefik-start

# Build and start containers
make build
make start

# Install development environment inside container
make dev-install
```

### 4. Configure OpenClaw

```bash
# Login to ClawHub (authenticates your Anthropic account)
docker exec -it <project-name>-gateway npx clawhub login

# Install skills
make install-skills
```

### 5. Approve Browser Device

1. Open the Web UI: `http://<project-name>.openclaw.localhost`
2. You'll see a device approval prompt
3. Approve the browser device to start chatting with agents

### 6. Start Developing!

Access your environment:
- **Web UI**: `http://<project-name>.openclaw.localhost`
- **VS Code IDE**: `http://<project-name>.code.localhost`
- **SSH**: `ssh -p <SSH_PORT> dev@localhost`

## Files You Must Customize

When creating a new project from this template, these files need customization:

### ✅ Automated by `make init`

- ✅ `.env` - Created with your project-specific values
- ✅ `package.json` - Project name updated

### ⚠️ Manual Customization (Optional)

- `.openclaw/openclaw.json` - Agent configuration (copied from template on first start)
- `README.md` - Update with your project-specific information
- `docker-compose.yml` - Already configured to use `.env` variables

### 🚫 Never Commit

The following are automatically generated and should **never** be committed:

- `.env` - Contains secrets
- `.openclaw/identity/` - Device keypairs
- `.openclaw/devices/paired.json` - Paired device tokens
- `.openclaw/agents/*/sessions/` - Agent conversation history
- `.openclaw/openclaw.json` - May contain Discord tokens (use template instead)

## Multi-Project Setup

You can run multiple projects simultaneously by using different project names and ports:

```bash
# Project 1
PROJECT_NAME=project-alpha SSH_PORT=2222 make build start

# Project 2
PROJECT_NAME=project-beta SSH_PORT=2223 make build start
```

Each project will have its own:
- Container names: `<project-name>-gateway`, `<project-name>-dev`
- URLs: `http://<project-name>.openclaw.localhost`
- Isolated agents and workspaces

## Template Reset (Danger Zone)

To reset the current project back to template state (⚠️ **destroys all project data**):

```bash
make template-reset
```

Then re-initialize:

```bash
make init
```

## Architecture

### Container Structure

- **Gateway Container**: Runs OpenClaw agents and web UI (full project mount)
- **Dev Container**: Development environment with VS Code Server, Node.js, and tools (optimized mount: apps/ only)

**Volumes:**
- Dev-server mounts the entire project root for full git compatibility
- Persistent `worktrees` volume for agent parallel work (survives container restarts)
- Gateway has full project access for editing all files and git operations

### Agent Roles

1. **Owner** (Claude Opus 4.6) - Default agent, architectural decisions, complex tasks
2. **QA Lead** (Claude Sonnet 4.5) - Test strategy, quality assurance
3. **Frontend Dev** (Claude Sonnet 4.5) - React, UI/UX, accessibility
4. **Backend Dev** (Claude Sonnet 4.5) - NestJS, APIs, database
5. **Tester** (Claude Sonnet 4.5) - Test implementation, E2E tests

### Git Worktrees (Parallel Development)

Agents use Git Worktrees so they can work simultaneously on different branches without conflicts.

```
~/project/              ← main branch (human / Owner)
~/worktrees/
├── frontend/           ← feat/fe-xxx (isolated checkout)
├── backend/            ← feat/be-xxx (isolated checkout)
└── tester/             ← feat/tt-xxx (isolated checkout)
```

**Workflow:**
1. Agent receives task → `scripts/worktree.sh create <agent> <branch>`
2. Worktree created with own branch + `pnpm install` + git identity
3. Agent works in `~/worktrees/<agent>/`
4. Push + create PR
5. `scripts/worktree.sh remove <agent>` → cleanup

**Benefits:**
- Multiple agents code in parallel (no branch conflicts)
- Human developers can work alongside agents
- Git identity auto-set per agent (correct commit attribution)
- Worktrees are ephemeral — created per task, removed after PR

**Helper commands:**
```bash
scripts/worktree.sh create frontend feat/fe-login  # Create
scripts/worktree.sh list                            # List active
scripts/worktree.sh remove frontend                 # Remove one
scripts/worktree.sh clean                           # Remove all
```

### Available Skills

The template includes 15+ specialized skills:
- **Development**: TypeScript, React, NestJS, Tailwind v4 + shadcn
- **Testing**: Testing Patterns, E2E Testing Patterns
- **Security**: Security Auditor, Security Scanner, Accessibility Auditor
- **DevOps**: GitHub Ops, Code Review, DevOps automation

## Pulling Template Updates

To pull updates from the template repository into your project:

```bash
# Add template as remote (once)
git remote add template <template-repository-url>

# Fetch and merge template updates
git fetch template
git merge template/main --allow-unrelated-histories

# Resolve conflicts (prioritize your project-specific changes)
```

**Note**: Always review changes carefully, especially to:
- `.openclaw/openclaw.json.template` (may have new features)
- `Makefile` (may have new commands)
- `docker-compose.yml` (may have new services or optimizations)

## Troubleshooting

### Container Name Conflicts

If you see "container name already exists":

```bash
docker ps -a | grep <project-name>
docker rm -f <project-name>-gateway <project-name>-dev
```

### Port Conflicts

If ports 2222 or 18789 are in use:

```bash
# Change SSH_PORT in .env
SSH_PORT=2223

# Or change gateway port in .openclaw/openclaw.json
"gateway": { "port": 18790 }
```

### Agent Not Responding

1. Check gateway logs: `docker logs <project-name>-gateway`
2. Verify ClawHub login: `docker exec -it <project-name>-gateway npx clawhub whoami`
3. Restart gateway: `docker restart <project-name>-gateway`

### Skills Not Working

```bash
# Re-install skills
make install-skills

# Verify installation
docker exec -it <project-name>-gateway npx openclaw skills list
```

## Contributing

If you make improvements to the template itself (not project-specific changes), consider submitting them back:

1. Fork the template repository
2. Create a feature branch
3. Make your changes to template files (not `.env` or generated files)
4. Submit a pull request

## License

[Add your license here]

## Support

For issues specific to:
- **OpenClaw**: See OpenClaw documentation
- **This template**: Create an issue in the template repository
- **Your project**: Document in your project's README

---

**Happy coding with your AI dev team!** 🚀
