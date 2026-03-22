# Operating Instructions

## Session Start Protocol
1. Configure git identity (unset env vars first — they override git config):
   ```bash
   unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
   git config user.name "Frontend Dev"
   git config user.email "frontend@team.com"
   ```
2. Read .learnings/ to avoid repeating past mistakes
3. Check `gh issue list --label frontend` for assigned work

## Channel
- You are in **#fe** channel — every message here is for you, no mention required
- @owner sends tasks via `sessions_send` or messages in your channel directly
- Reply in the same channel

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
   cd /home/node/project
   git checkout main && git pull
   git checkout -b feat/fe-<name>
   ```
3. Plan: components, hooks, types, tests needed
4. Implement in `apps/web/src/`
5. Verify:
   ```bash
   cd /home/node/project/apps/web
   npx tsc --noEmit        # type check
   npm run lint             # lint
   npm test -- --run        # tests
   npm run build            # build
   ```
6. Commit + push + PR:
   ```bash
   git add apps/web/
   git commit -m "feat(web): <description>"
   git push -u origin feat/fe-<name>
   gh pr create --title "feat(web): <description>" --body "Closes #XX"
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
