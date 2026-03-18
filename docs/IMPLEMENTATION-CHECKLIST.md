# Template Conversion Implementation Checklist

Use this checklist to track completion of the template conversion.

## ✅ Phase 1: Core Template Files (COMPLETED)

- [x] Create `.openclaw/openclaw.json.template` with placeholders
- [x] Create `make init` interactive initialization script
- [x] Create `.env.example` with all required variables
- [x] Create `TEMPLATE.md` comprehensive usage guide
- [x] Update `.gitignore` with secret exclusions
- [x] Update `Makefile` with template commands
- [x] Update `package.json` to template name
- [x] Update `docker-compose.yml` with environment variables
- [x] Create `verify-template.sh` verification script
- [x] Create `TEMPLATE-CONVERSION-SUMMARY.md` documentation

## 🔄 Phase 2: Documentation Updates (PENDING)

### README.md Updates

- [ ] Add template banner at top ("🎯 This is a reusable template")
- [ ] Add "Quick Start from Template" section
- [ ] Link to TEMPLATE.md and TEMPLATE-CONVERSION-SUMMARY.md
- [ ] Replace "0xthoth-dev-ai" with "openclaw-5-agent-template"
- [ ] Replace "@0xthoth" with "@myorg" or generic namespace
- [ ] Replace hardcoded URLs with `<project-name>` placeholders
- [ ] Add multi-project setup examples
- [ ] Add template update workflow
- [ ] Remove project-specific private information
- [ ] Add badges (optional but recommended)

**Helper Document**: `README-TEMPLATE-ADDITIONS.md`

**Quick Commands**:
```bash
# Backup first
cp README.md README.md.backup

# Automated replacements (review before committing)
sed -i '' 's/0xthoth-dev-ai/openclaw-5-agent-template/g' README.md
sed -i '' 's/@0xthoth/@myorg/g' README.md
sed -i '' 's/0xthoth\.code\.localhost/<project-name>.code.localhost/g' README.md
```

### SETUP.md Updates

- [ ] Add "Step 0: Initialize from Template" at top
- [ ] Add Configuration Reference table
- [ ] Replace "0xthoth-dev-ai" with `<PROJECT_NAME>`
- [ ] Replace hardcoded URLs with placeholders
- [ ] Update all docker exec commands to use variables
- [ ] Add multi-project setup tips
- [ ] Update prerequisites section
- [ ] Add template-specific troubleshooting
- [ ] Update Quick Start section
- [ ] Test all commands with actual values

**Helper Document**: `SETUP-TEMPLATE-ADDITIONS.md`

**Quick Commands**:
```bash
# Backup first
cp SETUP.md SETUP.md.backup

# Automated replacements
sed -i '' 's/0xthoth-dev-ai/<PROJECT_NAME>/g' SETUP.md
sed -i '' 's/0xthoth\.code\.localhost/<project>.code.localhost/g' SETUP.md
```

## 🧹 Phase 3: Clean Generated Data (PENDING)

**⚠️ WARNING**: This will delete all project-specific data!

### Option A: Using Makefile Command

```bash
make template-reset
# Type "RESET" when prompted
```

### Option B: Manual Cleanup

```bash
# Delete device identity
rm -rf .openclaw/identity/*
mkdir -p .openclaw/identity

# Delete devices
echo '[]' > .openclaw/devices/paired.json
echo '[]' > .openclaw/devices/pending.json

# Delete agent sessions and state
rm -rf .openclaw/agents/
rm -rf .openclaw/workspace-*/.openclaw/workspace-state.json

# Delete logs
rm -rf .openclaw/logs/

# Delete backups
rm -f .openclaw/openclaw.json.bak*
rm -f backup.json

# Copy template config to active config
cp .openclaw/openclaw.json.template .openclaw/openclaw.json
```

### Files to Verify Deleted

- [ ] `.openclaw/identity/device.json` (device keypairs)
- [ ] `.openclaw/identity/device-auth.json` (auth tokens)
- [ ] `.openclaw/devices/paired.json` (should be empty array `[]`)
- [ ] `.openclaw/agents/*/sessions/*` (all session files)
- [ ] `.openclaw/workspace-*/.openclaw/workspace-state.json` (state files)
- [ ] `.openclaw/logs/config-audit.jsonl` (audit logs)
- [ ] `.openclaw/openclaw.json.bak*` (all backup files)
- [ ] `backup.json` (legacy backup)
- [ ] `.openclaw/openclaw.json` (should match template exactly)

## 🔒 Phase 4: Security Verification (REQUIRED)

### Run Verification Script

```bash
chmod +x verify-template.sh
./verify-template.sh
```

This checks for:
- Discord bot tokens
- Gateway auth tokens
- Discord guild IDs
- Discord channel IDs
- Discord user IDs
- Old project name references
- Required template files
- Gitignore rules
- Environment variable usage

### Manual Verification

```bash
# Check for Discord tokens (should be none except in docs)
grep -r "MTQxxxxx...YOUR_BOT_TOKEN...xxxxx" . --exclude-dir={node_modules,data,.git} | grep -v "TEMPLATE-CONVERSION-SUMMARY\|IMPLEMENTATION-CHECKLIST"

# Check for guild IDs
grep -r "131701441050968xxxx" . --exclude-dir={node_modules,data,.git} | grep -v "TEMPLATE-CONVERSION-SUMMARY\|IMPLEMENTATION-CHECKLIST"

# Check for gateway tokens
grep -r "<GENERATE_ON_FIRST_START>" . --exclude-dir={node_modules,data,.git} | grep -v "TEMPLATE-CONVERSION-SUMMARY\|IMPLEMENTATION-CHECKLIST"

# Check .env is gitignored
git check-ignore .env
# Should output: .env

# Check openclaw.json is gitignored
git check-ignore .openclaw/openclaw.json
# Should output: .openclaw/openclaw.json
```

### Security Checklist

- [ ] No Discord bot tokens in tracked files
- [ ] No gateway auth tokens in tracked files
- [ ] No Discord guild/channel/user IDs in tracked files
- [ ] `.env` is gitignored
- [ ] `.openclaw/identity/` is gitignored
- [ ] `.openclaw/devices/paired.json` is gitignored
- [ ] `.openclaw/openclaw.json` is gitignored
- [ ] `.openclaw/openclaw.json.template` uses placeholders only
- [ ] `docker-compose.yml` uses environment variables
- [ ] `.env.example` has example values only

## 🧪 Phase 5: Testing (REQUIRED)

### Test 1: Template Initialization

```bash
# Backup current .env if exists
cp .env .env.backup || true

# Run init script
make init

# Enter test values:
# - Project name: test-project-123
# - Git user: test-bot
# - Git email: bot@test.local
# - SSH port: 2233
# - Password: testpass123
# - Anthropic API key: sk-ant-test
# - GitHub token: ghp_test
```

**Verify**:
- [ ] `.env` created with correct values
- [ ] `package.json` name updated to "test-project-123"
- [ ] Script displays next steps
- [ ] Script shows correct URLs

### Test 2: Container Startup

```bash
# Ensure Traefik is running
make traefik-start

# Build and start
make build
make start

# Check containers
docker ps | grep test-project-123
```

**Verify**:
- [ ] Containers named correctly: `test-project-123-gateway`, `test-project-123-dev`
- [ ] Both containers running
- [ ] No errors in logs: `docker logs test-project-123-gateway`
- [ ] Gateway generates new auth token (check logs)

### Test 3: Access Points

**Verify**:
- [ ] Web UI accessible: `http://test-project-123.openclaw.localhost`
- [ ] VS Code IDE accessible: `http://test-project-123.code.localhost`
- [ ] SSH accessible: `ssh -p 2233 dev@localhost` (password: testpass123)
- [ ] Gateway API responds: `curl http://test-project-123.openclaw.localhost/api/health`

### Test 4: Agent Configuration

```bash
# Check agents loaded
docker exec test-project-123-gateway openclaw agents list
```

**Verify**:
- [ ] 5 agents listed (owner, qa-lead, frontend, backend, tester)
- [ ] Owner is default agent
- [ ] Models correctly assigned (1 Opus, 4 Sonnet)

### Test 5: Multi-Project

```bash
# Start second project
PROJECT_NAME=test-project-456 SSH_PORT=2234 make start

# Check both running
docker ps | grep test-project
```

**Verify**:
- [ ] Both projects running simultaneously
- [ ] Different container names
- [ ] Different ports (2233 vs 2234)
- [ ] Different URLs accessible
- [ ] No interference between projects

### Test 6: Template Reset

```bash
# Cleanup test project
make stop
docker rm test-project-123-gateway test-project-123-dev

# Reset to template
make template-reset  # Type "RESET"
```

**Verify**:
- [ ] All generated files deleted
- [ ] `.openclaw/openclaw.json` matches template
- [ ] `paired.json` is empty array
- [ ] No agent sessions remain
- [ ] Ready for re-initialization

### Test 7: Git Operations

```bash
# Check what would be committed
git status

# Should NOT show:
# - .env
# - .openclaw/identity/
# - .openclaw/devices/paired.json
# - .openclaw/openclaw.json
# - .openclaw/agents/

# Should show (if modified):
# - .openclaw/openclaw.json.template
# - make init
# - TEMPLATE.md
# - Makefile
# - docker-compose.yml
# - package.json
```

**Verify**:
- [ ] No secrets in git status
- [ ] Only template files tracked
- [ ] .gitignore working correctly

## 📦 Phase 6: Repository Preparation (PENDING)

### Update Repository Settings

- [ ] Add repository description: "OpenClaw 5-agent AI dev team template with Owner, QA Lead, Frontend, Backend, and Tester agents"
- [ ] Add topics/tags: `openclaw`, `claude`, `ai-agents`, `docker`, `template`, `development-environment`
- [ ] Enable "Use this template" button (if GitHub)
- [ ] Set repository visibility (public/private)

### Add License

```bash
# Choose a license (MIT recommended for templates)
# Create LICENSE file
```

- [ ] Add LICENSE file
- [ ] Update README.md with license badge

### Create Release

```bash
# Tag first template version
git tag -a v1.0.0 -m "Initial template release - OpenClaw 5-Agent Template"
git push origin v1.0.0
```

- [ ] Create v1.0.0 tag
- [ ] Push tag to remote
- [ ] Create GitHub release (if applicable)

### Repository Documentation

- [ ] Update repository README (first page visitors see)
- [ ] Add `.github/ISSUE_TEMPLATE/` for bug reports
- [ ] Add `.github/PULL_REQUEST_TEMPLATE.md`
- [ ] Add `CONTRIBUTING.md` guidelines
- [ ] Add `.github/workflows/` for CI (optional)

## 🎨 Phase 7: Optional Enhancements (OPTIONAL)

### CI/CD

- [ ] Add GitHub Actions workflow to test template initialization
- [ ] Add workflow to verify no secrets committed
- [ ] Add workflow to test multi-project setup
- [ ] Add automated release process

### Developer Experience

- [ ] Add shell completion for Makefile targets
- [ ] Create VS Code workspace template
- [ ] Add recommended VS Code extensions list
- [ ] Create `.editorconfig` for consistent formatting

### Documentation

- [ ] Record setup video/screencast
- [ ] Create architecture diagram
- [ ] Add troubleshooting FAQ
- [ ] Create comparison with other setups
- [ ] Add performance tuning guide

### Advanced Features

- [ ] Add support for custom agent configurations
- [ ] Create agent personality templates
- [ ] Add skill marketplace integration
- [ ] Create project templates (web app, API, mobile, etc.)

## ✅ Final Checklist Before Distribution

- [ ] **Security**: `./verify-template.sh` passes with 0 errors
- [ ] **Testing**: All 7 test scenarios completed successfully
- [ ] **Documentation**: README.md and SETUP.md updated
- [ ] **Cleanup**: No generated data in repository
- [ ] **Git**: No secrets in git history
- [ ] **Validation**: Fresh clone + init + start works
- [ ] **Multi-project**: Tested running 2+ projects simultaneously
- [ ] **License**: LICENSE file added
- [ ] **Release**: v1.0.0 tagged and published

## 📝 Notes

- Restore original project: Use `.env.backup`, `README.md.backup`, `SETUP.md.backup`
- Template version: Track in `package.json` version field
- Breaking changes: Bump major version, document migration
- Keep template updated: Pull upstream OpenClaw changes regularly

## 🚀 Distribution

Once all checklists complete:

1. Commit all changes: `git add . && git commit -m "Convert to reusable template"`
2. Push to remote: `git push origin main`
3. Create release: Tag v1.0.0 and publish
4. Share repository URL with team/community
5. Monitor issues and pull requests
6. Keep template updated with OpenClaw releases

---

**Template Conversion Checklist v1.0**
**Last Updated**: 2026-03-18
**Status**: Phase 1 Complete, Phase 2-7 Pending
