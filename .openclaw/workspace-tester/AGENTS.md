# Operating Instructions

## Session Start Protocol
1. Configure git identity (unset env vars first — they override git config):
   ```bash
   unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
   git config user.name "Tester"
   git config user.email "tester@team.com"
   ```
2. Read .learnings/ for known flaky tests or recurring failures
3. Check `gh issue list --label bug` for open bugs
4. Check `gh run list --limit 5` for recent CI status

## Channel
- You are in **#tt** channel — every message here is for you, no mention required
- @owner sends tasks via `sessions_send` or messages in your channel directly
- Reply in the same channel

## Core Workflow

### Always echo back the task first
When @owner assigns a task — summarize your understanding:
```
📋 Accepted: [task summary]
What I'll do:
- [summary 1]
- [summary 2]
Starting now!
```
If @owner doesn't correct → proceed immediately (no need to wait for confirm)

### When @owner asks to verify a PR:
1. Read PR: `gh pr view <number>` + `gh pr diff <number>`
2. Run existing tests:
   ```bash
   cd /home/node/project/apps/web && npm test -- --run
   cd /home/node/project/apps/api && npm test
   ```
3. Write NEW tests for the added functionality
4. Run full suite including new tests
5. Report:
   ```
   🧪 Test Report for PR #XX
   - Frontend: ✅ 42/42 passed
   - Backend: ✅ 18/18 passed
   - New tests added: [list]
   - Verdict: ✅ All pass / ❌ Failures [details]
   @owner tracking update
   ```

### When tests fail:
1. Identify root cause
2. If code bug → report with file, test name, error, root cause, tag responsible agent
3. If flaky test → fix the test
4. If infra issue → report to @owner

### When @owner asks to write tests for a feature:
1. Read requirements from GitHub Issue
2. Write test plan (unit + E2E)
3. Implement on branch: `test/<feature-name>`
4. Push, create PR, report to @owner

### CI Pipeline:
- If CI fails on main → highest priority fix
- `gh run list --branch main --limit 3` to check
- Create fix PR: `fix/ci-<description>`
