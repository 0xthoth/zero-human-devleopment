# Troubleshooting

Common issues and solutions for the OpenClaw 5-Agent template.

---

## Agent Directories Not Created

**Problem:** `.openclaw/agents/` directories don't exist after cloning.

**Cause:** The `agents/` directory is in `.gitignore` to exclude runtime data.

**Solution:** The template includes `.gitkeep` files in each agent directory to ensure they're tracked by git. If missing, create them:

```bash
mkdir -p .openclaw/agents/{owner,frontend,backend,qa-lead,tester,main}/agent
touch .openclaw/agents/{owner,frontend,backend,qa-lead,tester,main}/agent/.gitkeep
```

---

## Agent Doesn't Respond to Messages

**Problem:** Messages in a channel get no response from the expected agent.

**Possible causes:**

1. **Wrong channel binding:** Each agent is bound to one channel. Check `openclaw.json` — the agent's `bindings` must include the correct channel ID.
2. **requireMention misconfigured:** All channels should have `requireMention: false` so agents respond to ALL messages (not just @mentions).
3. **Agent not started:** Run `openclaw agents list` to verify the agent is registered and active.
4. **Gateway needs restart:** After config changes, always run `openclaw gateway restart`.

---

## devDependencies Not Installed (NODE_ENV=production)

**Problem:** `pnpm install` skips devDependencies, causing build/test failures.

**Cause:** `NODE_ENV=production` in `docker-compose.yml` or `.env` tells pnpm to skip devDependencies.

**Solution:** Set `NODE_ENV=development` in your `.env` file or `docker-compose.yml`:

```yaml
environment:
  - NODE_ENV=development
```

---

## pnpm-workspace.yaml Not Mounted

**Problem:** Dev-server can't resolve workspace packages, `pnpm install` fails.

**Cause:** `pnpm-workspace.yaml` is not mounted into the dev-server container.

**Solution:** Ensure `docker-compose.yml` includes:

```yaml
volumes:
  - ./pnpm-workspace.yaml:/home/${DEV_USER:-dev}/project/pnpm-workspace.yaml:ro
```

---

## Git Identity Shows Wrong Author

**Problem:** Commits show `project-bot` instead of the agent's identity (e.g., `Frontend Dev Agent`).

**Cause:** `GIT_AUTHOR_NAME` and `GIT_COMMITTER_NAME` environment variables override `git config` settings.

**Solution:** Each agent should unset env vars before configuring git identity:

```bash
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
git config user.name "Frontend Dev Agent"
git config user.email "frontend@team.com"
```

This is already configured in each agent's `AGENTS.md` session start protocol.

---

## Bot Ignores Its Own Messages

**Problem:** Agent-to-agent communication doesn't work — bots ignore messages from other bots.

**Cause:** By default, Discord bots ignore messages from other bots to prevent loops.

**Solution:** Use `sessions_send` for cross-agent communication instead of posting messages in channels. This bypasses the bot-message filter.

---

## Config Changes Not Taking Effect

**Problem:** Changes to `openclaw.json` don't seem to apply.

**Solution:** Always restart the gateway after config changes:

```bash
openclaw gateway restart
# or: make gateway-restart
```

Hot-reload for `agents.list` is unreliable — restart is the safe approach.

---

## ClawHub Rate Limits

**Problem:** `clawhub install` or `clawhub update` fails with rate limit errors.

**Solution:** ClawHub allows 120 requests/minute. Wait 1-2 minutes between bulk operations.

---

## Skills Installed in Wrong Directory

**Problem:** Skills end up in `skills/skills/<name>` instead of `skills/<name>`.

**Solution:** Move them to the correct location:

```bash
mv .openclaw/skills/skills/<name> .openclaw/skills/
```

Make sure to `cd` into `.openclaw/skills/` before running `clawhub install`.
