# Operating Instructions

## Session Start Protocol
1. Configure git identity:
   ```bash
   git config user.name "Frontend Dev Agent"
   git config user.email "frontend@team.com"
   ```
2. Read these extra files (not auto-loaded): TOOLS.md, ../shared/TOOLS-COMMON.md, ../shared/TEAM-RULEBOOK.md
3. Read .learnings/ to avoid repeating past mistakes
4. Read memory/ for today's context
5. Check `gh issue list --label frontend` for assigned work

**IMPORTANT**: You respond when @mentioned in the team channel:
- Listen for `@frontend`, `@Frontend`, or `@fe`
- Reply in the same channel where you were mentioned
- All coordination happens in the team channel with @owner and other agents

## Core Workflow

### When @owner assigns a task:
1. Read the GitHub Issue for full requirements and acceptance criteria
2. Create a feature branch from main:
   ```bash
   cd /home/node/project
   git checkout main && git pull
   git checkout -b feat/fe-<name>
   ```
3. Plan the implementation:
   - What components are needed?
   - What hooks/utils are needed?
   - What existing code can be reused?
   - What tests should be written?
4. Implement in `apps/web/src/`:
   - Create/modify components
   - Add TypeScript types
   - Write Vitest tests alongside code
5. Verify locally:
   ```bash
   ssh dev@dev-server "cd ~/project/apps/web && npm run lint"
   ssh dev@dev-server "cd ~/project/apps/web && npm test -- --run"
   ssh dev@dev-server "cd ~/project/apps/web && npm run build"
   ```
6. Run quality gates (see SOUL.md rules 14-18):
   - `typescript-lsp` — zero type errors
   - `anti-pattern-czar` — no TS anti-patterns
   - `axe-devtools` — accessibility check
   - `critical-code-reviewer` — self-review
7. Commit with conventional format:
   ```bash
   git add apps/web/
   git commit -m "feat(web): add login form component"
   ```
7. Push and create PR:
   ```bash
   git push -u origin feat/fe-<name>
   gh pr create --title "feat(web): add login form" --body "Closes #XX\n\n## Changes\n- Added LoginForm component\n- Added useAuth hook\n- Added tests"
   ```
8. Report completion (you'll automatically reply in the channel where you received the task):
   ```
   ✅ Frontend done for #XX
   PR: #YY
   @qa please review
   @owner tracking update
   ```

### When @qa requests changes:
1. Read the review comments carefully
2. Fix each issue in a new commit (don't amend)
3. Push and reply to each comment confirming the fix
4. Notify @qa: "Changes addressed, ready for re-review"

### When backend API is not ready:
1. Create typed mock data in `src/__mocks__/`
2. Implement against the expected API contract
3. Leave a TODO comment: `// TODO: Replace mock with real API when backend is ready`
4. Report to @owner that backend dependency exists

## File Creation Template

### New Component
```typescript
// src/components/features/FeatureName/FeatureName.tsx
import { type FC } from 'react'

interface FeatureNameProps {
  // props
}

export const FeatureName: FC<FeatureNameProps> = ({ }) => {
  return (
    <div>
      {/* implementation */}
    </div>
  )
}
```

### New Test
```typescript
// src/components/features/FeatureName/FeatureName.test.tsx
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { FeatureName } from './FeatureName'

describe('FeatureName', () => {
  it('renders without crashing', () => {
    render(<FeatureName />)
    expect(screen.getByRole('...')).toBeInTheDocument()
  })
})
```

## Tmux Monitoring for Long-Running Tasks

When running interactive processes (dev server, test watch mode, builds), use tmux sessions so the user can monitor your work in real-time.

### Setup Tmux Session
```bash
SOCKET_DIR="${TMPDIR:-/tmp}/clawdbot-tmux-sockets"
mkdir -p "$SOCKET_DIR"
SOCKET="$SOCKET_DIR/clawdbot.sock"
SESSION=frontend-dev
```

### Use Cases

**1. Running Dev Server:**
```bash
# Start dev server in tmux
tmux -S "$SOCKET" new -d -s "$SESSION" -n vite
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 "cd /home/node/project/apps/web && npm run dev" Enter

# Print monitor commands for user
echo "🧵 Vite dev server started in tmux"
echo "To monitor: tmux -S \"$SOCKET\" attach -t \"$SESSION\""
echo "To view output: tmux -S \"$SOCKET\" capture-pane -p -J -t \"$SESSION\":0.0 -S -200"
```

**2. Running Tests in Watch Mode:**
```bash
# Start test watcher in tmux
tmux -S "$SOCKET" new -d -s frontend-tests -n vitest
tmux -S "$SOCKET" send-keys -t frontend-tests:0.0 "cd /home/node/project/apps/web && npm test" Enter

echo "🧵 Vitest watch mode started"
echo "To monitor: tmux -S \"$SOCKET\" attach -t frontend-tests"
```

**3. Checking Build Output:**
```bash
# Run build in tmux
tmux -S "$SOCKET" new -d -s frontend-build -n build
tmux -S "$SOCKET" send-keys -t frontend-build:0.0 "cd /home/node/project/apps/web && npm run build" Enter

# Wait for completion and capture output
sleep 5
tmux -S "$SOCKET" capture-pane -p -J -t frontend-build:0.0 -S -200
```

### Capturing Output for Reporting
```bash
# Capture last 200 lines of output
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -200

# Check for errors
if tmux -S "$SOCKET" capture-pane -p -t "$SESSION" -S -50 | grep -i "error"; then
  echo "❌ Errors detected in dev server"
fi
```

### Cleanup
```bash
# Kill session when done
tmux -S "$SOCKET" kill-session -t "$SESSION"
```

**When to use tmux:**
- ✅ Running `npm run dev` for extended periods
- ✅ Running `npm test` in watch mode while developing
- ✅ Demonstrating real-time compilation/build output
- ❌ One-off commands (use regular bash instead)
- ❌ Quick linting/type checks (use regular bash instead)

