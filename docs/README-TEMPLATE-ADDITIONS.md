# README.md Template Additions

Add this content to the top of your README.md to make it template-ready:

```markdown
# OpenClaw 5-Agent Template

🎯 **This is a reusable template** - Clone and customize for your own projects!

> A production-ready development environment with 5 AI agents (Owner, QA Lead, Frontend Dev, Backend Dev, Tester) powered by Claude, running in Docker containers with full VS Code integration.

## Quick Start from Template

### 1. Clone and Initialize

\`\`\`bash
git clone <this-repository-url> my-new-project
cd my-new-project

# Run interactive initialization
chmod +x make init
make init
\`\`\`

You'll be prompted for:
- Project name (e.g., `my-awesome-project`)
- API keys (Anthropic, GitHub)
- Configuration values (SSH port, git user, etc.)

### 2. Start Your Environment

\`\`\`bash
# Start Traefik reverse proxy (once per machine)
make traefik-start

# Build and start project containers
make build
make start

# Install development dependencies
make dev-install
\`\`\`

### 3. Configure OpenClaw Agents

\`\`\`bash
# Login to ClawHub
docker exec -it <your-project-name>-gateway npx clawhub login

# Install all skills
make install-skills
\`\`\`

### 4. Access Your Environment

- **Web UI**: `http://<your-project-name>.openclaw.localhost`
- **VS Code IDE**: `http://<your-project-name>.code.localhost`
- **SSH Access**: `ssh -p <SSH_PORT> dev@localhost`

Approve the browser device in the Web UI to start chatting with your AI agents!

---

## Template Documentation

- **[TEMPLATE.md](./TEMPLATE.md)** - Complete template usage guide
- **[TEMPLATE-CONVERSION-SUMMARY.md](./TEMPLATE-CONVERSION-SUMMARY.md)** - Technical conversion details
- **[SETUP.md](./SETUP.md)** - Detailed setup instructions

## Features

- ✅ **5 Specialized AI Agents** - Owner (Opus 4.6), QA Lead, Frontend, Backend, Tester (all Sonnet 4.5)
- ✅ **15+ Pre-installed Skills** - TypeScript, React, NestJS, Security, Testing, DevOps
- ✅ **Full Development Environment** - VS Code Server, Node.js, SSH access
- ✅ **Multi-Project Support** - Run multiple independent projects simultaneously
- ✅ **Docker-based** - Consistent, reproducible environments
- ✅ **Traefik Integration** - Clean URLs with automatic routing

## Multi-Project Setup

Run multiple projects on the same machine:

\`\`\`bash
# Terminal 1 - Project Alpha
PROJECT_NAME=project-alpha SSH_PORT=2222 make start

# Terminal 2 - Project Beta
PROJECT_NAME=project-beta SSH_PORT=2223 make start
\`\`\`

Each project gets isolated:
- Containers: `<project-name>-gateway`, `<project-name>-dev`
- URLs: `http://<project-name>.openclaw.localhost`
- Agents and workspaces

## What Gets Customized

The `make init` script configures:

- ✏️ Project name (used in container names, URLs)
- ✏️ Git identity (name, email for commits)
- ✏️ API keys (Anthropic, GitHub)
- ✏️ SSH port (for terminal access)
- ✏️ Dev user password

All other configuration stays template-default.

## Template Updates

To pull updates from the template repository:

\`\`\`bash
# Add template remote (once)
git remote add template <template-repo-url>

# Fetch and merge updates
git fetch template
git merge template/main --allow-unrelated-histories
\`\`\`

Review changes to `.openclaw/openclaw.json.template`, `Makefile`, and `docker-compose.yml`.

---

## 📖 Original Project Documentation Below

<!-- Keep your existing README content below this line -->
\`\`\`

## Instructions for Updating README.md

1. **Backup current README.md**:
   ```bash
   cp README.md README.md.backup
   ```

2. **Add template section** at the top using the content above

3. **Update existing sections**:
   - Replace "0xthoth-dev-ai" with "openclaw-5-agent-template" in titles
   - Replace "@0xthoth" with "<your-namespace>" in examples
   - Replace hardcoded URLs like "0xthoth.code.localhost" with "<project-name>.code.localhost"
   - Keep technical details, architecture, and development sections

4. **Add badges** (optional):
   ```markdown
   [![Template](https://img.shields.io/badge/template-ready-brightgreen)]()
   [![OpenClaw](https://img.shields.io/badge/openclaw-5--agents-blue)]()
   [![Docker](https://img.shields.io/badge/docker-ready-blue?logo=docker)]()
   ```

5. **Remove project-specific details**:
   - Personal API keys or tokens
   - Private repository references
   - Organization-specific URLs or domains

## Sections to Keep (Make Generic)

Keep these sections but make them generic:

- **Architecture** - Describe the 5-agent system
- **Development Workflow** - How to work with agents
- **Skills** - List of available skills
- **Troubleshooting** - Common issues and solutions
- **Contributing** - How to improve the template

## Example Search & Replace

Use these patterns to update:

```bash
# In README.md
s/0xthoth-dev-ai/openclaw-5-agent-template/g
s/@0xthoth/@myorg/g
s/0xthoth\.code\.localhost/<project-name>.code.localhost/g
s/0xthoth\.openclaw\.localhost/<project-name>.openclaw.localhost/g
s/bot@0xthoth\.dev/bot@example.com/g
```

Or with sed:
```bash
sed -i '' 's/0xthoth-dev-ai/openclaw-5-agent-template/g' README.md
sed -i '' 's/@0xthoth/@myorg/g' README.md
sed -i '' 's/0xthoth\.code\.localhost/<project-name>.code.localhost/g' README.md
```

## Final Checklist

Before committing updated README.md:

- [ ] Added "🎯 This is a reusable template" banner
- [ ] Added Quick Start from Template section
- [ ] Linked to TEMPLATE.md and TEMPLATE-CONVERSION-SUMMARY.md
- [ ] Replaced all "0xthoth-dev-ai" with template name
- [ ] Replaced all "@0xthoth" with generic namespace
- [ ] Replaced hardcoded URLs with placeholders
- [ ] Removed personal/private information
- [ ] Kept technical architecture documentation
- [ ] Added multi-project setup examples
- [ ] Described what gets customized by init script
