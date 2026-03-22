# Tools — Frontend Dev

> Also read: ../shared/TOOLS-COMMON.md for shared tools (gh CLI, git, skills, self-improvement)

## Project Discovery
On first task, discover the stack from the project:
```bash
ssh dev@dev-server "cd ~/project && cat package.json"
ssh dev@dev-server "ls ~/project/apps/ 2>/dev/null || ls ~/project/packages/ 2>/dev/null || ls ~/project/src/ 2>/dev/null"
```

Read the frontend app's `package.json` to find available scripts, dependencies, and dev tools.

## Commands via Dev-Server SSH
Run builds and tests inside the dev-server (isolated env with Node.js, git).

**IMPORTANT: Use tmux for all commands so the human can track your activity!**

```bash
# Discover available scripts first
ssh dev@dev-server "tmux send-keys -t agent-frontend 'cd ~/project/<frontend-app> && cat package.json | grep -A 20 scripts' Enter"

# Then run discovered commands, e.g.:
ssh dev@dev-server "tmux send-keys -t agent-frontend 'cd ~/project/<frontend-app> && npm run lint' Enter"
ssh dev@dev-server "tmux send-keys -t agent-frontend 'cd ~/project/<frontend-app> && npm test' Enter"
ssh dev@dev-server "tmux send-keys -t agent-frontend 'cd ~/project/<frontend-app> && npm run build' Enter"
```

**Why tmux?** The human can watch your work in real-time: `make tmux-watch agent=frontend`

## File Conventions
Follow the project's existing conventions. Common patterns:
- Components: `PascalCase.tsx` or `PascalCase/index.tsx`
- Hooks: `useCamelCase.ts`
- Utils: `camelCase.ts`
- Types: `*.types.ts` or co-located
- Tests: co-located with source (e.g., `*.test.tsx`, `*.spec.tsx`)

## OpenClaw Skills Available

Skills provide specialized knowledge. Available skills may vary per project — check what's installed.

### Core Skills (Use These Always)

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `typescript-lsp` | TypeScript type checking and LSP diagnostics | Before every PR — run type checks |
| `anti-pattern-czar` | Detect TypeScript anti-patterns | Before PR — catch swallowed errors, `any` casts |
| `axe-devtools` | Accessibility testing (WCAG) | After building any UI component |
| `critical-code-reviewer` | Rigorous code review | Before creating PR — self-review |

### Situational Skills

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `lb-zod-skill` | Zod validation library docs | Form validation, API response parsing |
| `lb-tailwindcss-skill` | Tailwind CSS documentation | If project uses Tailwind |
| `react-perf` | React performance patterns | If project uses React |
| `lb-motion-skill` | Motion/Framer Motion docs | When adding animations |
| `neo-api-to-ts-interface` | Generate TS interfaces from API responses | When integrating with backend APIs |
| `sovereign-test-generator` | Auto-generate test suites | When building new components |
| `anti-slop-design` | Prevent generic AI-looking UI | When designing new pages |
