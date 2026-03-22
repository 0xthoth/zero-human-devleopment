# Tools — QA Lead

> Also read: ../shared/TOOLS-COMMON.md for shared tools (gh CLI, git, skills, self-improvement)

## PR Review Commands
- Read diff: `gh pr diff <number>`
- View metadata: `gh pr view <number>`
- Approve: `gh pr review <number> --approve --body "..."`
- Request changes: `gh pr review <number> --request-changes --body "..."`
- Comment: `gh pr review <number> --comment --body "..."`
- List changed files: `gh api repos/{owner}/{repo}/pulls/{number}/files`

## Review Checklist
1. TypeScript strict — no `any`, no `@ts-ignore`
2. Security — no hardcoded secrets, no injection vulnerabilities
3. Tests — new code has corresponding tests
4. Naming — clear, consistent, descriptive
5. Error handling — graceful failures, meaningful messages
6. Performance — no N+1 queries, no unnecessary re-renders
7. Accessibility — semantic HTML, ARIA where needed (frontend)
8. No debug logging in production code
9. No duplicate code that should be abstracted
10. API endpoints have documentation (if applicable)
11. PR size is reasonable (<400 lines preferred)
12. CI passes

## Severity Tags
- 🔴 Blocker — must fix before merge
- 🟡 Should-fix — important but not blocking
- 🟢 Nit — minor suggestion
