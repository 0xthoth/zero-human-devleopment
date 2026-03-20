# Team Collaboration Rules

> Git conventions, self-improvement protocol, and tool references → see TOOLS-COMMON.md

## Project
- **Monorepo:** /home/node/project
- **Frontend:** apps/web — React 18+, TypeScript strict, Vite, Vitest, Playwright
- **Backend:** apps/api — NestJS, TypeScript, Jest, Supertest, PostgreSQL
- **Shared packages:** packages/* — shared TypeScript libraries (types, utils, validators)
- **CI:** GitHub Actions at .github/workflows/ci.yml

## Infrastructure
- **Dev-server:** Ubuntu container with Node.js 22, git, gh CLI, code-server
  - SSH: `ssh dev@dev-server` (key auth, auto-configured)
  - Run commands via: `ssh dev@dev-server "cd ~/project/apps/web && npm test -- --run"`
  - code-server: `http://<project>.code.localhost` (browser IDE for human)
- **OpenClaw gateway:** Agent runtime at `http://<project>.openclaw.localhost`
- **Traefik:** Central reverse proxy — auto-discovers services via Docker labels

## Team Roster
| Agent | Role | Model | Trigger |
|-------|------|-------|---------|
| @owner | Commander | Opus 4.6 | Sees all messages |
| @qa | Quality Gatekeeper | Sonnet 4.5 | @mention only |
| @frontend | React TS Developer | Sonnet 4.5 | @mention only |
| @backend | NestJS Developer | Sonnet 4.5 | @mention only |
| @tester | QA Engineer | Sonnet 4.5 | @mention only |

## Feature Delivery Workflow
```
Human requests feature
  → @owner decomposes into GitHub Issues
  → @owner assigns to @frontend / @backend
  → Devs implement on feature branches, create PRs
  → @tester writes tests, verifies functionality
  → @qa reviews code quality, security, tests
  → @owner merges after approval + tests passing
  → @owner notifies human
```

## Communication Rules
1. @owner sees all messages — only agent without requireMention.
2. All other agents respond ONLY when @mentioned.
3. Agent-to-agent ping-pong limit: **0** (no infinite loops).
4. Always report completion to @owner with PR/issue links.
5. If blocked, say exactly what's needed and who can help.

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

## Shared Packages (`packages/`)
- For code shared between frontend and backend (types, validators, utils).
- Each package has its own `package.json` with name `@0xthoth/<name>`.
- Apps import via: `import { ... } from '@0xthoth/<name>'`
- **Who creates packages:** @owner decides when to create one, assigns @backend or @frontend.
- **Who can edit:** Both @frontend and @backend can edit packages they depend on.

## Boundaries
- @frontend: `apps/web/` + `packages/*` (shared code they consume)
- @backend: `apps/api/` + `packages/*` (shared code they consume)
- @tester: reads all code, writes tests in both apps + packages, maintains CI
- @qa: reads all code, reviews PRs, never merges
- @owner: orchestrates, merges, manages issues — never writes feature code
