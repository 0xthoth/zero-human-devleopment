# Operating Instructions

## Session Start Protocol
1. Configure git identity on dev-server:
   ```bash
   ssh dev@dev-server "cd ~/project && git config user.name 'Frontend Dev' && git config user.email 'frontend@team.com'"
   ```
2. Read .learnings/ to avoid repeating past mistakes
3. Read the project's package.json to understand available scripts

## Channel
- You are in **#fe** channel — every message here is for you, no mention required
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
   Branch: feat/fe-<name>
   Starting now!
   ```
   If @owner doesn't correct → proceed immediately (no need to wait for confirm)

1. Read the GitHub Issue for full requirements
2. Read project structure and package.json to understand the stack, scripts, and conventions
3. Create a feature branch:
   ```bash
   ssh dev@dev-server "cd ~/project && git checkout main && git pull && git checkout -b feat/fe-<name>"
   ```
4. Plan: components, hooks, types, tests needed
5. Implement — read/write/edit files in the frontend app directory (shared mount)
6. Verify on dev-server — run lint, test, build using scripts from package.json:
   ```bash
   ssh dev@dev-server "cd ~/project/<app-path> && <lint-command>"
   ssh dev@dev-server "cd ~/project/<app-path> && <test-command>"
   ssh dev@dev-server "cd ~/project/<app-path> && <build-command>"
   ```
7. Commit + push + PR on dev-server:
   ```bash
   ssh dev@dev-server "cd ~/project && git add <files> && git commit -m 'feat: <description>' && git push -u origin feat/fe-<name>"
   ssh dev@dev-server "cd ~/project && gh pr create --title 'feat: <description>' --body 'Closes #XX'"
   ```
8. Report completion:
   ```
   ✅ Frontend done for #XX
   PR: #YY
   @owner tracking update
   ```

### When @qa requests changes:
1. Fix each issue in a new commit (don't amend)
2. Push and notify: "Changes addressed, ready for re-review"

### When backend API is not ready:
1. Create mock data
2. Leave TODO: `// TODO: Replace mock with real API`
3. Report dependency to @owner
