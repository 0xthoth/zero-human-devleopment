# Shared Tools Reference

## GitHub CLI (`gh`)
- `gh issue create --title "..." --label "..." --body "..."` — create issue
- `gh issue list` — list open issues
- `gh issue view <number>` — read issue details
- `gh pr create --title "..." --body "..."` — create PR
- `gh pr list` — list open PRs
- `gh pr view <number>` — view PR metadata
- `gh pr diff <number>` — read PR diff
- `gh pr review <number> --approve` — approve PR
- `gh pr review <number> --request-changes --body "..."` — request changes
- `gh pr checks <number>` — verify CI status
- `gh pr merge <number> --squash` — squash merge
- `gh run list --limit 5` — recent CI runs
- `gh run view <id> --log-failed` — failed CI logs

## Dev-Server (SSH)
The dev-server is an isolated Ubuntu container with Node.js, npm, git, and gh CLI.
- SSH: `ssh dev@dev-server` (key auth, no password)
- Run commands: `ssh dev@dev-server "cd ~/project/apps/web && npm test -- --run"`
- Use `~/project` inside dev-server (same code as /home/node/project)
- **First run:** `ssh dev@dev-server "cd ~/project && npm install"` (installs Linux-native deps)
- If `npm test` or `npm run build` fails with binary errors, re-run `npm install` inside dev-server

## Git Conventions
- Project repo: /home/node/project
- Default branch: main
- Branch naming: `feat/<scope>-<name>`, `fix/<scope>-<name>`, `test/<name>`
- Scopes: `fe` (frontend), `be` (backend), `ci` (pipeline), `docs`
- Commit format: conventional — `feat(web): add login form`
- Never force-push to main
- Never run `git reset --hard` without human approval
- Never commit secrets, .env files, or credentials

## File Operations
- Read files before editing — never blindly overwrite
- Use exec tool for shell commands
- Use read/write/edit tools for file operations

## Skills
- **github-pro**: PR automation, CI monitoring, issue management
- **self-improving-agent**: Error/learning/feature-request logging

## Self-Improvement Protocol
- On errors: log to `.learnings/ERRORS.md` using `[ERR-YYYYMMDD-XXX]` format
- On corrections/discoveries: log to `.learnings/LEARNINGS.md` using `[LRN-YYYYMMDD-XXX]`
- On human feature requests: log to `.learnings/FEATURE_REQUESTS.md` using `[FR-YYYYMMDD-XXX]`
- Review .learnings/ at every session start
- Promote patterns with 3+ occurrences to SOUL.md or AGENTS.md
- Write daily summary to memory/YYYY-MM-DD.md
