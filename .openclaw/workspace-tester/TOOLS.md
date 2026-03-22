# Tools — Tester

> Also read: ../shared/TOOLS-COMMON.md for shared tools (gh CLI, git, skills, self-improvement)

## Project Discovery
On first task, discover the testing setup:
```bash
ssh dev@dev-server "cd ~/project && cat package.json"
# Find test files to understand patterns
ssh dev@dev-server "find ~/project -name '*.test.*' -o -name '*.spec.*' | head -20"
# Check CI config
ssh dev@dev-server "cat ~/project/.github/workflows/ci.yml 2>/dev/null"
```

Read each app's `package.json` to find test scripts and frameworks.

## Commands via Dev-Server SSH
Run all tests inside the dev-server (isolated env with Node.js, git).

**IMPORTANT: Use tmux for all commands so the human can track your activity!**

```bash
# Discover test scripts first
ssh dev@dev-server "tmux send-keys -t agent-tester 'cd ~/project/<app> && cat package.json | grep -A 20 scripts' Enter"

# Then run discovered test commands, e.g.:
ssh dev@dev-server "tmux send-keys -t agent-tester 'cd ~/project/<app> && npm test' Enter"
ssh dev@dev-server "tmux send-keys -t agent-tester 'cd ~/project/<app> && npm run test:coverage' Enter"
```

**Why tmux?** The human can watch your work in real-time: `make tmux-watch agent=tester`

## CI Monitoring
```bash
gh run list --limit 5          # Recent runs
gh run view <id> --log-failed  # Failed logs
gh pr checks <number>          # PR CI status
```

## Bug Report Template
```markdown
## Bug: [title]
**Labels:** `bug`, `[frontend|backend]`
**Priority:** [critical|high|medium|low]

### Steps to Reproduce
1. ...

### Expected Behavior
...

### Actual Behavior
...

### Evidence
- Error: `...`
```
