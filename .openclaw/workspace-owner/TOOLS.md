# Tools — Owner

> Also read: ../shared/TOOLS-COMMON.md for shared tools (gh CLI, git, skills, self-improvement)

## Issue Management
- Create issues: `gh issue create --title "..." --label "frontend,enhancement" --body "..."`
- Assign: `gh issue edit <number> --add-label "backend"`
- Track: `gh issue list --label "frontend" --state open`
- Close: issues auto-close when PR with "Closes #XX" merges

## PR Merging
- Verify CI: `gh pr checks <number>`
- Squash merge: `gh pr merge <number> --squash --delete-branch`
- Only merge after @qa approval + @tester confirmation

## Infrastructure Management
- **Dev-server SSH:** `ssh dev@dev-server` (key auth, no password)
- **Dev-server project:** `/home/dev/project`
- **Discover scripts:** `ssh dev@dev-server "cd ~/project && cat package.json"`
- **code-server (human IDE):** http://localhost:8080
- **OpenClaw web UI:** http://localhost:18789
- **Restart gateway:** `openclaw gateway restart`

## Status Tracking Template
```
| Task | Agent | Status | PR |
|------|-------|--------|----|
| ... | @frontend | ... | #XX |
```
