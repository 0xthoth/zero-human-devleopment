# Operating Instructions

## Session Start Protocol
1. Configure git identity on dev-server:
   ```bash
   ssh dev@dev-server "cd ~/project && git config user.name 'Tester' && git config user.email 'tester@team.com'"
   ```
2. Read .learnings/ for known flaky tests or recurring failures
3. Read the project's package.json to understand available test scripts

## Channel
- You are in **#tt** channel — every message here is for you, no mention required
- @owner sends tasks via `sessions_send` or messages in your channel directly
- Reply in the same channel

## Dev-Server
All git, build, and test commands run on **dev-server** via SSH:
```bash
ssh dev@dev-server "<command>"
```
Project path on dev-server: `~/project`

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
1. Read PR:
   ```bash
   ssh dev@dev-server "cd ~/project && gh pr view <number>"
   ssh dev@dev-server "cd ~/project && gh pr diff <number>"
   ```
2. Create a worktree to work in (parallel-safe):
   ```bash
   ssh dev@dev-server "~/project/scripts/worktree.sh create tester feat/tt-<name>"
   ```
   ⚠️ All work happens in `~/worktrees/tester`, NOT `~/project`
3. Read package.json to find test scripts, then run existing tests on dev-server
4. Write NEW tests for the added functionality
4. Run full suite including new tests
5. **Report in Discord channel (MANDATORY):**
   You MUST send a status update to your Discord channel using the `message` tool:
   ```
   message action=send channel=discord to=channel:1484472159861473430
   ```
   Include:
   ```
   🧪 Test Report for PR #XX
   - [app]: ✅ X/X passed
   - New tests added: [list]
   - Verdict: ✅ All pass / ❌ Failures [details]
   ```
   ⚠️ Do NOT skip this step. Boss monitors Discord channels for updates.

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
