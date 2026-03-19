# Tools — Backend Dev

> Also read: ../shared/TOOLS-COMMON.md for shared tools (gh CLI, git, skills, self-improvement)

## Stack
- **NestJS** with TypeScript strict
- **PostgreSQL** database
- **Jest** + **Supertest** for tests
- **Swagger** (@nestjs/swagger) for API docs
- **Code:** /home/node/project/apps/api

## Commands via Dev-Server SSH
Run builds and tests inside the dev-server (isolated env with Node.js, npm, git):
```bash
ssh dev@dev-server "cd ~/project/apps/api && npm run lint"
ssh dev@dev-server "cd ~/project/apps/api && npm test"
ssh dev@dev-server "cd ~/project/apps/api && npm run build"
ssh dev@dev-server "cd ~/project/apps/api && npm run start:dev"
ssh dev@dev-server "cd ~/project/apps/api && npm run test:e2e"
```

## Commands (local, from apps/api/)
```bash
npm run start:dev     # Dev server with hot reload
npm run build         # Production build
npm run lint          # ESLint
npm test              # Unit tests
npm run test:e2e      # E2E tests
npm run test:cov      # Coverage
```

## NestJS Module Structure
```
src/modules/<name>/
├── <name>.module.ts
├── <name>.controller.ts
├── <name>.controller.spec.ts
├── <name>.service.ts
├── <name>.service.spec.ts
├── <name>.entity.ts
└── dto/
    ├── create-<name>.dto.ts
    └── update-<name>.dto.ts
```

## OpenClaw Skills Available

### Tier 1 — Use These Always

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `agent-nestjs-skills` | NestJS best practices — modules, guards, interceptors, pipes | Every task — follow NestJS architecture patterns |
| `typescript-lsp` | TypeScript type checking and LSP diagnostics | Before every PR — verify zero type errors |
| `anti-pattern-czar` | Detect TypeScript error handling anti-patterns | Before PR — catch swallowed errors, `any`, unsafe assertions |
| `secure-auth-patterns` | JWT, OAuth2, bcrypt, RBAC patterns | When implementing auth, guards, or protected routes |
| `api-security` | API security — CORS, helmet, rate limiting, input validation | Every new endpoint — check security posture |
| `postgres-perf` | PostgreSQL optimization — indexing, EXPLAIN, connection pooling | When writing queries, entities, or migrations |

### Tier 2 — Use Per Situation

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `test-sentinel` | Generate and run Jest + Supertest test suites | When building new modules — auto-generate tests |
| `backend-patterns` | Backend architecture patterns and API design blueprints | When designing new modules or service layers |
| `api-dev` | Scaffold, test, document REST APIs | When creating new endpoints with Swagger docs |
| `database-designer` | Schema design, migration planning, table optimization | When creating new entities or planning migrations |
| `code-security-audit` | OWASP Top 10 vulnerability scanning | Before PR — scan for SQL injection, broken auth, XSS |
| `ggshield-scanner` | Detect 500+ types of hardcoded secrets | Before every commit — prevent credential leaks |
| `lb-zod-skill` | Zod validation library docs | Config validation, env var parsing, runtime schemas |

### Tier 3 — Use When Needed

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `bug-audit` | Node.js bug hunting — 200+ real-world pitfalls | When debugging memory leaks, event loop issues, async traps |
| `debug-methodology` | Systematic root-cause debugging | When stuck — prevents shotgun debugging and workaround stacking |
| `neo-es6-refactor` | Modernize JS/TS to ES6+ | When refactoring legacy code patterns |
| `agentic-devops` | Docker, process management, log analysis | When working with Docker, health checks, deployment |
| `secrets-management` | Secrets in CI/CD — Vault, AWS Secrets Manager | When configuring env vars across environments |

## Skill Usage Workflow

### Before Writing Code
1. Check `agent-nestjs-skills` for correct NestJS patterns
2. Check `backend-patterns` for architecture decisions
3. Check `database-designer` if creating new entities
4. Check `secure-auth-patterns` if implementing auth

### While Writing Code
5. Use `api-dev` to scaffold endpoints with Swagger docs
6. Use `test-sentinel` to generate Jest + Supertest tests
7. Use `postgres-perf` to optimize queries and indexes
8. Use `lb-zod-skill` for config/env validation

### Before Creating PR
9. Run `typescript-lsp` — zero type errors
10. Run `anti-pattern-czar` — no TS anti-patterns
11. Run `code-security-audit` — OWASP Top 10 clean
12. Run `ggshield-scanner` — no hardcoded secrets
13. Run `api-security` — verify endpoint security

## Swagger Decorators
```typescript
@ApiTags('auth')
@ApiOperation({ summary: 'Login' })
@ApiResponse({ status: 200, description: 'JWT token' })
@ApiResponse({ status: 401, description: 'Invalid credentials' })
```

## Test Template
```typescript
describe('Service', () => {
  let service: Service;
  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [Service],
    }).compile();
    service = module.get<Service>(Service);
  });
  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
```
