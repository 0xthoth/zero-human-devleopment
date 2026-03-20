# Tools — Tester

> Also read: ../shared/TOOLS-COMMON.md for shared tools (gh CLI, git, skills, self-improvement)

## Test Frameworks
| Type | Tool | Location |
|------|------|----------|
| Unit (FE) | Vitest | `apps/web/**/*.test.tsx` |
| Unit (BE) | Jest | `apps/api/**/*.spec.ts` |
| E2E (FE) | Playwright | `apps/web/e2e/` |
| E2E (BE) | Supertest | `apps/api/test/*.e2e-spec.ts` |

## Commands via Dev-Server SSH
Run all tests inside the dev-server (isolated env with Node.js, npm, git).

**IMPORTANT: Use tmux for all commands so the human can track your activity!**

```bash
# Frontend tests in tmux session: agent-tester
ssh dev@dev-server "tmux send-keys -t agent-tester 'cd ~/project/apps/web && npm test -- --run' Enter"
ssh dev@dev-server "tmux send-keys -t agent-tester 'cd ~/project/apps/web && npm test -- --run --coverage' Enter"
ssh dev@dev-server "tmux send-keys -t agent-tester 'cd ~/project/apps/web && npx playwright test' Enter"

# Backend tests in tmux session: agent-tester
ssh dev@dev-server "tmux send-keys -t agent-tester 'cd ~/project/apps/api && npm test' Enter"
ssh dev@dev-server "tmux send-keys -t agent-tester 'cd ~/project/apps/api && npm run test:e2e' Enter"
ssh dev@dev-server "tmux send-keys -t agent-tester 'cd ~/project/apps/api && npm run test:cov' Enter"
```

**Why tmux?** The human can watch your work in real-time: `make tmux-watch agent=tester`

## Commands (local)
```bash
# Frontend (from apps/web/)
npm test -- --run              # Unit tests
npm test -- --run --coverage   # With coverage
npx playwright test            # E2E

# Backend (from apps/api/)
npm test                       # Unit tests
npm run test:e2e               # E2E
npm run test:cov               # Coverage
```

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

## Playwright Template
```typescript
import { test, expect } from '@playwright/test'

test('feature works', async ({ page }) => {
  await page.goto('/')
  await expect(page).toHaveTitle(/.../)
})
```
