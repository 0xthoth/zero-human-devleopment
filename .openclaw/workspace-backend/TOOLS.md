# Tools — Backend Dev

> Also read: ../shared/TOOLS-COMMON.md for shared tools (gh CLI, git, skills, self-improvement)

## Project Discovery
On first task, discover the stack from the project:
```bash
ssh dev@dev-server "cd ~/project && cat package.json"
ssh dev@dev-server "ls ~/project/apps/ 2>/dev/null || ls ~/project/packages/ 2>/dev/null || ls ~/project/src/ 2>/dev/null"
```

Read the backend app's `package.json` to find available scripts, dependencies, and dev tools.

## Commands via Dev-Server SSH
Run builds and tests inside the dev-server (isolated env with Node.js, git).

**IMPORTANT: Use tmux for all commands so the human can track your activity!**

```bash
# Discover available scripts first
ssh dev@dev-server "tmux send-keys -t agent-backend 'cd ~/project/<backend-app> && cat package.json | grep -A 20 scripts' Enter"

# Then run discovered commands, e.g.:
ssh dev@dev-server "tmux send-keys -t agent-backend 'cd ~/project/<backend-app> && npm run lint' Enter"
ssh dev@dev-server "tmux send-keys -t agent-backend 'cd ~/project/<backend-app> && npm test' Enter"
ssh dev@dev-server "tmux send-keys -t agent-backend 'cd ~/project/<backend-app> && npm run build' Enter"
```

**Why tmux?** The human can watch your work in real-time: `make tmux-watch agent=backend`

## OpenClaw Skills Available

Skills provide specialized knowledge. Available skills may vary per project — check what's installed.

### Core Skills (Use These Always)

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `typescript-lsp` | TypeScript type checking and LSP diagnostics | Before every PR — verify zero type errors |
| `anti-pattern-czar` | Detect TypeScript anti-patterns | Before PR — catch swallowed errors, `any` |
| `code-security-audit` | OWASP Top 10 vulnerability scanning | Before PR — scan for injection, broken auth |
| `ggshield-scanner` | Detect hardcoded secrets | Before every commit |

### Situational Skills

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `agent-nestjs-skills` | NestJS best practices | If project uses NestJS |
| `secure-auth-patterns` | JWT, OAuth2, bcrypt, RBAC patterns | When implementing auth |
| `api-security` | API security — CORS, rate limiting | Every new endpoint |
| `postgres-perf` | PostgreSQL optimization | If project uses PostgreSQL |
| `database-designer` | Schema design, migration planning | When creating new entities |
| `backend-patterns` | Backend architecture patterns | When designing new modules |
| `api-dev` | Scaffold, test, document REST APIs | When creating new endpoints |
| `test-sentinel` | Generate test suites | When building new modules |
| `lb-zod-skill` | Zod validation library docs | Config validation, runtime schemas |
| `bug-audit` | Node.js bug hunting | When debugging issues |
| `debug-methodology` | Systematic debugging | When stuck on a problem |
