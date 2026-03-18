# SETUP.md Template Additions

Add this section at the very beginning of SETUP.md:

```markdown
# OpenClaw 5-Agent Template Setup

## Step 0: Initialize from Template (First Time Only)

If you're setting up a new project from this template, run the initialization script first:

\`\`\`bash
# Make the script executable
chmod +x make init

# Run interactive initialization
make init
\`\`\`

This will:
- Prompt for your project name (e.g., `my-project`)
- Collect your API keys (Anthropic, GitHub)
- Generate a `.env` file with your configuration
- Update `package.json` with your project name

After initialization, the rest of this setup guide applies to your customized project.

---
\`\`\`

## Instructions for Updating SETUP.md

### 1. Add Step 0 (above) at the very top

### 2. Update all examples with placeholders:

**Find and replace patterns:**

```bash
# Project names
0xthoth-dev-ai → <PROJECT_NAME>
0xthoth → <project>

# URLs
0xthoth.code.localhost → <project>.code.localhost
0xthoth.openclaw.localhost → <project>.openclaw.localhost

# Email addresses
bot@0xthoth.dev → bot@example.com

# Container names
0xthoth-dev-ai-gateway → <PROJECT_NAME>-gateway
0xthoth-dev-ai-dev → <PROJECT_NAME>-dev
```

### 3. Update command examples:

**Before:**
```bash
docker exec -it 0xthoth-dev-ai-gateway npx clawhub login
ssh -p 2222 dev@localhost
```

**After:**
```bash
docker exec -it <PROJECT_NAME>-gateway npx clawhub login
# Or use the environment variable:
docker exec -it $PROJECT_NAME-gateway npx clawhub login

ssh -p <SSH_PORT> dev@localhost
# Or with default:
ssh -p ${SSH_PORT:-2222} dev@localhost
```

### 4. Add environment variable references:

Add this section after Step 0:

```markdown
## Configuration Reference

The template uses environment variables from `.env`:

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `PROJECT_NAME` | Project identifier | `project` | `my-awesome-app` |
| `SSH_PORT` | SSH access port | `2222` | `2222` |
| `DEV_USER` | Dev container username | `dev` | `dev` |
| `DEV_USER_PASSWORD` | Dev container password | (required) | `your-secure-password` |
| `GIT_USER_NAME` | Git commit author | `project-bot` | `myproject-bot` |
| `GIT_USER_EMAIL` | Git commit email | `bot@example.com` | `bot@myorg.com` |
| `ANTHROPIC_API_KEY` | Claude API key | (required) | `sk-ant-xxxxx` |
| `GITHUB_TOKEN` | GitHub API token | (optional) | `ghp_xxxxx` |

All commands in this guide use these variables automatically via the Makefile.
\`\`\`

### 5. Update section titles:

**Before:**
```markdown
## Setting up 0xthoth-dev-ai
```

**After:**
```markdown
## Setting up Your OpenClaw Project
```

### 6. Add multi-project notes:

Add this tip box after the main setup steps:

```markdown
> **💡 Tip: Running Multiple Projects**
>
> You can run multiple projects simultaneously by using different project names:
>
> \`\`\`bash
> # Project 1
> PROJECT_NAME=project-alpha SSH_PORT=2222 make start
>
> # Project 2
> PROJECT_NAME=project-beta SSH_PORT=2223 make start
> \`\`\`
>
> Each project gets isolated containers and unique URLs.
\`\`\`

### 7. Update prerequisites section:

Add template-specific requirements:

```markdown
## Prerequisites

- Docker & Docker Compose
- Make (build automation)
- Git
- **Anthropic API Key** ([Get one here](https://console.anthropic.com/))
- (Optional) GitHub Personal Access Token for GitHub operations

**System Requirements:**
- macOS, Linux, or WSL2 on Windows
- 8GB+ RAM (16GB recommended for multiple projects)
- 20GB+ free disk space
\`\`\`

### 8. Sed command for batch updates:

Run these commands to update SETUP.md automatically:

```bash
# macOS
sed -i '' 's/0xthoth-dev-ai/<PROJECT_NAME>/g' SETUP.md
sed -i '' 's/0xthoth\.code\.localhost/<project>.code.localhost/g' SETUP.md
sed -i '' 's/0xthoth\.openclaw\.localhost/<project>.openclaw.localhost/g' SETUP.md
sed -i '' 's/@0xthoth/@myorg/g' SETUP.md
sed -i '' 's/bot@0xthoth\.dev/bot@example.com/g' SETUP.md

# Linux (remove the '')
sed -i 's/0xthoth-dev-ai/<PROJECT_NAME>/g' SETUP.md
sed -i 's/0xthoth\.code\.localhost/<project>.code.localhost/g' SETUP.md
```

### 9. Add troubleshooting for template issues:

Add this section to troubleshooting:

```markdown
## Troubleshooting Template Setup

### "Project name already exists" error

If you see container name conflicts:

\`\`\`bash
# Check existing containers
docker ps -a | grep <old-project-name>

# Remove old containers
docker rm -f <old-project-name>-gateway <old-project-name>-dev

# Or use template reset
make template-reset  # Type "RESET" to confirm
\`\`\`

### Init script fails to update package.json

Manually edit `package.json`:

\`\`\`json
{
  "name": "your-project-name",
  ...
}
\`\`\`

### .env not loading

Ensure `.env` is in the project root (same directory as `Makefile` and `docker-compose.yml`).

Verify with:
\`\`\`bash
cat .env
\`\`\`

### Wrong project URLs

If URLs point to wrong project:

1. Check `PROJECT_NAME` in `.env`
2. Restart containers: `make restart`
3. Clear browser cache for `*.openclaw.localhost`
\`\`\`

### 10. Update first-time setup steps:

**Before:**
```markdown
1. Clone the repository
2. Configure `.env`
3. Start Traefik
```

**After:**
```markdown
1. Clone the template repository
2. Run `make init` (interactive setup)
3. Review generated `.env`
4. Start Traefik (once per machine): `make traefik-start`
5. Build containers: `make build`
6. Start project: `make start`
```

## Complete Example Replacement

Here's a complete before/after example:

**Before:**
```markdown
## Quick Start

1. Clone repo: `git clone <url>`
2. Start traefik: `make traefik-start`
3. Build: `make build`
4. Start: `make start`
5. Access: http://0xthoth.code.localhost
6. Login to ClawHub: `docker exec -it 0xthoth-dev-ai-gateway npx clawhub login`
```

**After:**
```markdown
## Quick Start

1. Clone template: `git clone <template-url> my-project && cd my-project`
2. Initialize: `make init` (provide project name, API keys)
3. Start Traefik (once): `make traefik-start`
4. Build: `make build`
5. Start: `make start`
6. Access: `http://<your-project>.code.localhost`
7. Login to ClawHub: `docker exec -it <your-project>-gateway npx clawhub login`
8. Install skills: `make install-skills`

Replace `<your-project>` with the name you chose during initialization.
```

## Final Checklist

- [ ] Added Step 0: Initialize from Template
- [ ] Added Configuration Reference table
- [ ] Replaced all hardcoded project names with `<PROJECT_NAME>`
- [ ] Replaced all hardcoded URLs with `<project>` placeholder
- [ ] Updated all Docker commands to use variables
- [ ] Added multi-project setup tip
- [ ] Updated prerequisites section
- [ ] Added template-specific troubleshooting
- [ ] Updated Quick Start section
- [ ] Tested all commands with actual project names
