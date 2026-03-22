# Team Collaboration Rules

> Git conventions, self-improvement protocol, and tool references → see TOOLS-COMMON.md

## 🚨 CRITICAL: Branch Protection
- **NEVER push directly to master/main** — always use feature branch + PR
- **ALL changes require a Pull Request** — code, docs, config, everything
- **ALL PRs require human review before merge** — no exceptions
- **No force-push to any shared branch** without explicit human approval
- This applies to ALL agents including @owner

## Project Discovery
On first task, every agent should:
1. Read the project's `README.md` and root `package.json`
2. Explore directory structure to understand the layout
3. Identify frontend app, backend app, shared packages, and CI config
4. Discover the package manager from lockfiles (package-lock.json → npm, pnpm-lock.yaml → pnpm, yarn.lock → yarn)
5. Read each app's `package.json` for available scripts

**Do not assume any specific framework, database, or tooling.** Discover it from the project.

## Project Layout
- **Project root:** /home/node/project
- **Frontend app:** Discover from project structure
- **Backend app:** Discover from project structure
- **Shared packages:** Discover from project structure (e.g., `packages/*`, `libs/*`)
- **CI:** Check `.github/workflows/` or equivalent

## Infrastructure
- **Dev-server:** Ubuntu container with Node.js, git, gh CLI
  - SSH: `ssh dev@dev-server` (key auth, auto-configured)
  - Discover scripts: `ssh dev@dev-server "cd ~/project && cat package.json"`
  - code-server: `http://<project>.code.localhost` (browser IDE for human)
- **OpenClaw gateway:** Agent runtime at `http://<project>.openclaw.localhost`
- **Traefik:** Central reverse proxy — auto-discovers services via Docker labels

## Team Roster
| Agent | Role | Model | Channel |
|-------|------|-------|---------|
| @owner | Commander | Opus 4.6 | #general + #team |
| @qa | Quality Gatekeeper | Sonnet 4.5 | #qa |
| @frontend | Frontend Developer | Sonnet 4.5 | #fe |
| @backend | Backend Developer | Sonnet 4.5 | #be |
| @tester | QA Engineer | Sonnet 4.5 | #tt |

All agents use `requireMention: false` — they respond to ALL messages in their dedicated channel.

## Discord Channel Layout
| Channel | Purpose |
|---------|---------|
| `#general` | Human ↔ Owner direct conversation, planning |
| `#team` | Status board — Owner monitors, agents post updates |
| `#fe` | Frontend agent's workspace |
| `#be` | Backend agent's workspace |
| `#tt` | Tester agent's workspace |
| `#qa` | QA Lead agent's workspace |

## Feature Delivery Workflow
```
Human requests feature in #general
  → @owner decomposes into GitHub Issues
  → @owner posts tasks to agent channels (#fe, #be, etc.)
  → Devs implement on feature branches, create PRs
  → @owner asks @tester in #tt to verify
  → @owner asks @qa in #qa to review
  → @owner merges after approval + tests passing
  → @owner notifies human in #general
```

## Communication Rules
1. Each agent monitors its own channel — no @mention needed within a channel.
2. To assign work to an agent, post in their channel (or use sessions_send for cross-agent communication).
3. Always report completion to @owner with PR/issue links.
4. If blocked, say exactly what's needed and who can help.
5. Agent-to-agent communication is enabled via agentToAgent.

## PR Requirements
- Linked to a GitHub Issue
- Has tests (unit at minimum, E2E for critical paths)
- CI passes (lint + tests)
- Reviewed by @qa (approved, no blockers)
- Verified by @tester (tests pass, functionality confirmed)

## Priority Levels
| Level | Meaning | Response Time |
|-------|---------|---------------|
| Critical | Security, data loss, main broken | Immediate |
| High | Feature blocker, failing tests | Same session |
| Medium | Bug, degraded functionality | Next assignment |
| Low | Cosmetic, nit | Backlog |

## Escalation
1. Blocked after 2 attempts → @owner
2. @owner can't resolve → human
3. Security issue → stop all work, alert human
4. CI breaks on main → top priority for all

## Shared Packages
- For code shared between frontend and backend (types, validators, utils).
- Follow the existing naming convention in the project.
- **Who creates packages:** @owner decides when to create one, assigns @backend or @frontend.
- **Who can edit:** Both @frontend and @backend can edit packages they depend on.

## Boundaries
- @frontend: frontend app + shared packages they consume
- @backend: backend app + shared packages they consume
- @tester: reads all code, writes tests in both apps + packages, maintains CI
- @qa: reads all code, reviews PRs, never merges
- @owner: orchestrates, merges, manages issues — never writes feature code
