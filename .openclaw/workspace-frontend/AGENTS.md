# Operating Instructions

## Session Start Protocol
1. Configure git identity on dev-server:
   ```bash
   ssh dev@dev-server "cd ~/project && git config user.name 'Frontend Dev' && git config user.email 'frontend@team.com'"
   ```
2. Read .learnings/ to avoid repeating past mistakes
3. Check `ssh dev@dev-server "cd ~/project && gh issue list --label frontend"` for assigned work

## Channel
- You are in **#fe** channel — every message here is for you, no mention required
- @owner sends tasks via `sessions_send` or messages in your channel directly
- Reply in the same channel

## Dev-Server
All code, git, build, and test commands run on **dev-server** via SSH:
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
2. Create a feature branch:
   ```bash
   ssh dev@dev-server "cd ~/project && git checkout main && git pull && git checkout -b feat/fe-<name>"
   ```
3. Plan: components, hooks, types, tests needed
4. Implement — read/write/edit files at `/home/node/project/apps/web/src/` (shared mount)
5. Verify on dev-server:
   ```bash
   ssh dev@dev-server "cd ~/project/apps/web && pnpm run lint"
   ssh dev@dev-server "cd ~/project/apps/web && pnpm test -- --run"
   ssh dev@dev-server "cd ~/project/apps/web && pnpm run build"
   ```
6. Commit + push + PR on dev-server:
   ```bash
   ssh dev@dev-server "cd ~/project && git add apps/web/ && git commit -m 'feat(web): <description>' && git push -u origin feat/fe-<name>"
   ssh dev@dev-server "cd ~/project && gh pr create --title 'feat(web): <description>' --body 'Closes #XX'"
   ```
7. Report completion:
   ```
   ✅ Frontend done for #XX
   PR: #YY
   @owner tracking update
   ```

### When @qa requests changes:
1. Fix each issue in a new commit (don't amend)
2. Push and notify: "Changes addressed, ready for re-review"

### When backend API is not ready:
1. Create mock data in `src/__mocks__/`
2. Leave TODO: `// TODO: Replace mock with real API`
3. Report dependency to @owner
