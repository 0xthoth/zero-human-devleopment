# Operating Instructions

## Session Start Protocol
1. Configure git identity on dev-server:
   ```bash
   ssh dev@dev-server "cd ~/project && git config user.name 'Backend Dev' && git config user.email 'backend@team.com'"
   ```
2. Read .learnings/ to avoid repeating past mistakes
3. Check `ssh dev@dev-server "cd ~/project && gh issue list --label backend"` for assigned work

## Channel
- You are in **#be** channel — every message here is for you, no mention required
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
   Branch: feat/be-<name>
   Starting now!
   ```
   If @owner doesn't correct → proceed immediately (no need to wait for confirm)

1. Read the GitHub Issue for full requirements
2. Create a feature branch:
   ```bash
   ssh dev@dev-server "cd ~/project && git checkout main && git pull && git checkout -b feat/be-<name>"
   ```
3. Plan (follow SOUL.md NestJS Best Practices):
   - Modules, entities, DTOs, endpoints, tests, auth, migrations
4. Implement — read/write/edit files at `/home/node/project/apps/api/src/` (shared mount)
5. Verify on dev-server:
   ```bash
   ssh dev@dev-server "cd ~/project/apps/api && pnpm run lint"
   ssh dev@dev-server "cd ~/project/apps/api && pnpm test"
   ssh dev@dev-server "cd ~/project/apps/api && pnpm run build"
   ```
6. Commit + push + PR on dev-server:
   ```bash
   ssh dev@dev-server "cd ~/project && git add apps/api/ && git commit -m 'feat(api): <description>' && git push -u origin feat/be-<name>"
   ssh dev@dev-server "cd ~/project && gh pr create --title 'feat(api): <description>' --body 'Closes #XX'"
   ```
7. Report completion:
   ```
   ✅ Backend done for #XX
   Endpoints: POST /api/<path>, GET /api/<path>
   PR: #YY
   @owner tracking update
   ```

### When @qa requests changes:
1. Fix each issue in a new commit (don't amend)
2. Push and notify: "Changes addressed, ready for re-review"

### When frontend needs an API that doesn't exist yet:
1. Design the endpoint contract (method, path, request/response types)
2. Share contract with @frontend so they can mock
3. Implement, test, notify @frontend when ready
