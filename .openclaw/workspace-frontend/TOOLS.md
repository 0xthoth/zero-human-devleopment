# Tools — Frontend Dev

> Also read: ../shared/TOOLS-COMMON.md for shared tools (gh CLI, git, skills, self-improvement)

## Stack
- **React 18+** with TypeScript strict
- **Vite** bundler
- **Vitest** + **@testing-library/react** for tests
- **Code:** /home/node/project/apps/web

## Commands via Dev-Server SSH
Run builds and tests inside the dev-server (isolated env with Node.js, npm, git).

**IMPORTANT: Use tmux for all commands so the human can track your activity!**

```bash
# All commands should run in your dedicated tmux session: agent-frontend
ssh dev@dev-server "tmux send-keys -t agent-frontend 'cd ~/project/apps/web && npm run lint' Enter"
ssh dev@dev-server "tmux send-keys -t agent-frontend 'cd ~/project/apps/web && npm test -- --run' Enter"
ssh dev@dev-server "tmux send-keys -t agent-frontend 'cd ~/project/apps/web && npm run build' Enter"
ssh dev@dev-server "tmux send-keys -t agent-frontend 'cd ~/project/apps/web && npm run dev' Enter"
```

**Why tmux?** The human can watch your work in real-time: `make tmux-watch agent=frontend`

## Commands (local, from apps/web/)
```bash
npm run dev          # Dev server
npm run build        # Production build
npm run lint         # ESLint
npm test -- --run    # Tests (single run)
```

## File Conventions
- Components: `PascalCase.tsx` → `src/components/`
- Hooks: `useCamelCase.ts` → `src/hooks/`
- Utils: `camelCase.ts` → `src/utils/`
- Types: `*.types.ts` or co-located
- Tests: `*.test.tsx` co-located with source
- Services: `src/services/` for API clients

## OpenClaw Skills Available

### Tier 1 — Use These Always

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `typescript-lsp` | TypeScript type checking and LSP diagnostics | Before every PR — run type checks on .ts/.tsx files |
| `lb-tailwindcss-skill` | Complete Tailwind CSS documentation | When writing any styles — correct class names, responsive design, theming |
| `lb-zod-skill` | Zod validation library docs | Form validation, API response parsing, runtime type enforcement |
| `axe-devtools` | Accessibility testing (WCAG) | After building any UI component — check for a11y violations |
| `react-perf` | React performance optimization patterns | When components re-render too much, bundle size grows, or lists get large |
| `anti-pattern-czar` | Detect TypeScript anti-patterns | Before PR — catch swallowed errors, `any` casts, unsafe assertions |

### Tier 2 — Use Per Situation

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `sovereign-test-generator` | Auto-generate test suites | When building new components — generate Vitest + Testing Library tests |
| `anti-slop-design` | Prevent generic AI-looking UI | When designing new pages — enforce unique, polished visual identity |
| `shadcn-theme-default` | shadcn/ui theming with OKLCH + Tailwind v4 | When setting up or customizing the design system theme |
| `neo-api-to-ts-interface` | Generate TS interfaces from API responses | When integrating with backend APIs — auto-type responses |
| `critical-code-reviewer` | Rigorous code review | Before creating PR — self-review for logic errors, naming, architecture |

### Tier 3 — Use When Needed

| Skill | What It Does | When to Use |
|-------|-------------|-------------|
| `lb-motion-skill` | Motion/Framer Motion docs | When adding animations or transitions |
| `sovereign-accessibility-auditor` | WCAG 2.1 compliance audit | Deep accessibility review for critical user-facing pages |
| `kj-ui-ux-pro-max` | UI/UX design principles | Spacing systems, typography scales, interaction patterns |
| `neo-es6-refactor` | Modernize JS/TS to ES6+ | When refactoring legacy code patterns |
| `deploy-pilot` | Build validation + deployment | When deploying to Vercel or running deploy checks |

## Skill Usage Workflow

### Before Writing Code
1. Check `react-perf` for optimization patterns if building complex components
2. Check `lb-tailwindcss-skill` for correct utility classes
3. Check `lb-zod-skill` if building forms or API integrations

### While Writing Code
4. Use `typescript-lsp` to verify types compile
5. Use `sovereign-test-generator` to scaffold tests
6. Use `neo-api-to-ts-interface` to type API responses

### Before Creating PR
7. Run `anti-pattern-czar` to catch TS anti-patterns
8. Run `axe-devtools` to verify accessibility
9. Run `critical-code-reviewer` for self-review
10. Run `sovereign-accessibility-auditor` for WCAG compliance

## Component Template
```typescript
import { type FC } from 'react'

interface Props { /* ... */ }

export const Name: FC<Props> = ({ }) => {
  return <div>{/* ... */}</div>
}
```

## Test Template
```typescript
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { Name } from './Name'

describe('Name', () => {
  it('renders', () => {
    render(<Name />)
    expect(screen.getByRole('...')).toBeInTheDocument()
  })
})
```
