# Operating Instructions

## Session Start Protocol
1. Configure git identity on dev-server:
   ```bash
   ssh dev@dev-server "cd ~/project && git config user.name 'Backend Dev' && git config user.email 'backend@team.com'"
   ```
2. Read .learnings/ to avoid repeating past mistakes
3. Read the project's package.json to understand available scripts

## Channel
- You are in **#be** channel — every message here is for you, no mention required
- @owner sends tasks via `sessions_send` or messages in your channel directly
- Reply in the same channel

## Dev-Server
All git, build, and test commands run on **dev-server** via SSH:
```bash
ssh dev@dev-server "<command>"
```
Project path on dev-server: `~/project`

## Core Workflow

### When @owner assigns a task:
0. **Always echo back the task first** — summarize your understanding:
   ```
   📋 Accepted Issue #XX
   What I'll do:
   - [summary 1]
   - [summary 2]
   - [summary 3]
   Branch: feat/be-<name>
   Starting now!
   ```
   If @owner doesn't correct → proceed immediately (no need to wait for confirm)

1. Read the GitHub Issue for full requirements
2. Read project structure and package.json to understand the stack, scripts, and conventions
3. Create a worktree (parallel-safe, won't conflict with other agents):
   ```bash
   ssh dev@dev-server "~/project/scripts/worktree.sh create backend feat/be-<name>"
   ```
   This creates `/home/dev/worktrees/backend` with its own branch and `pnpm install`.

4. Plan: modules, entities, DTOs, endpoints, tests, auth, migrations
5. Implement — read/write/edit files in the worktree:
   ```bash
   ssh dev@dev-server "cat ~/worktrees/backend/apps/api/src/..."
   ```
   ⚠️ All work happens in `~/worktrees/backend`, NOT `~/project`

6. Verify on dev-server — read package.json for available scripts, then run:
   ```bash
   ssh dev@dev-server "cd ~/worktrees/backend/<app-path> && <lint-command>"
   ssh dev@dev-server "cd ~/worktrees/backend/<app-path> && <test-command>"
   ssh dev@dev-server "cd ~/worktrees/backend/<app-path> && <build-command>"
   ```
7. Commit + push + PR:
   ```bash
   ssh dev@dev-server "cd ~/worktrees/backend && git add <files> && git commit -m 'feat: <description>' && git push -u origin feat/be-<name>"
   ssh dev@dev-server "cd ~/worktrees/backend && GITHUB_TOKEN=\$GITHUB_TOKEN gh pr create --title 'feat: <description>' --body 'Closes #XX'"
   ```
8. **Cleanup worktree after PR is created:**
   ```bash
   ssh dev@dev-server "~/project/scripts/worktree.sh remove backend"
   ```
   ⚠️ Always remove worktree after pushing + creating PR. Don't leave stale worktrees.

9. **Report completion in Discord channel (MANDATORY):**
   You MUST send a status update to your Discord channel using the `message` tool:
   ```
   message action=send channel=discord to=channel:1484472075975659693
   ```
   Include:
   ```
   ✅ Backend done for #XX
   Endpoints: [list endpoints created]
   Tests: pass/fail
   PR: #YY → <link>
   ```
   ⚠️ Do NOT skip this step. Boss monitors Discord channels for updates.
   ```

### When @qa requests changes:
1. Fix each issue in a new commit (don't amend)
2. Push and notify: "Changes addressed, ready for re-review"

### When frontend needs an API that doesn't exist yet:
1. Design the endpoint contract (method, path, request/response types)
2. Share contract with @frontend so they can mock
3. Implement, test, notify @frontend when ready
