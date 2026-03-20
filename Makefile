-include .env
PROJECT_NAME ?= project
DEV_USER ?= dev
SSH_PORT ?= 2222
OPENCLAW_GATEWAY_CONTAINER ?= $(PROJECT_NAME)-gateway

.PHONY: help start stop restart build logs ssh \
        traefik-start traefik-stop traefik-logs \
        openclaw-setup openclaw-config-setup openclaw-cmd openclaw-devices-list openclaw-devices-id openclaw-devices-approve openclaw-devices-auto-approve openclaw-gateway-token \
        openclaw-discord-token openclaw-restart \
        update-password fix-data-permission dev-install \
        install-skills update-skills status init template-reset \
        verify-template verify gateway-start gateway-stop gateway-restart gateway-status agents-list

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-24s\033[0m %s\n", $$1, $$2}'

# --- Core ---

start: ## Start this project (dev-server + openclaw)
	@docker network inspect traefik_net >/dev/null 2>&1 || docker network create traefik_net
	docker compose up -d

stop: ## Stop this project
	docker compose down

restart: ## Restart this project
	docker compose restart

build: ## Rebuild dev-server image (no cache)
	docker compose build --no-cache dev-server

logs: ## Follow this project's logs
	docker compose logs -f

status: ## Show all running containers for this project
	@echo "Project: $(PROJECT_NAME)"
	@echo "---"
	@echo "Code-server: http://$(PROJECT_NAME).code.localhost"
	@echo "OpenClaw:    http://$(PROJECT_NAME).openclaw.localhost"
	@echo "SSH:         ssh $(DEV_USER)@127.0.0.1 -p $(SSH_PORT)"
	@echo "---"
	@docker compose ps

# --- Dev Server ---

ssh: ## SSH into dev-server
	ssh $(DEV_USER)@127.0.0.1 -p $(SSH_PORT)

update-password: ## Update dev-server password (prompts for input)
	@read -sp "New password: " pw && echo && \
	docker compose exec dev-server bash -c "echo '$(DEV_USER):'"$$pw"'' | chpasswd" && \
	echo "Password updated."

fix-data-permission: ## Fix ./data ownership to UID 1000
	sudo chown -R 1000:1000 ./data

dev-install: ## Install pnpm and dependencies (auto-installs pnpm if needed)
	@echo "Checking for pnpm..."
	@docker compose exec -u $(DEV_USER) dev-server bash -c "command -v pnpm >/dev/null 2>&1 || (mkdir -p ~/.npm-global && npm config set prefix ~/.npm-global && npm install -g pnpm@9.15.4 && echo 'export PATH=~/.npm-global/bin:\$$PATH' >> ~/.bashrc)"
	@echo "Installing dependencies with pnpm..."
	@docker compose exec -u $(DEV_USER) dev-server bash -c "export PATH=~/.npm-global/bin:\$$PATH && cd /home/$(DEV_USER)/projects && pnpm install"

# --- Traefik (central reverse proxy) ---

traefik-start: ## Start Traefik (run once, shared across all projects)
	docker compose -f docker-compose-traefik.yml up -d

traefik-stop: ## Stop Traefik
	docker compose -f docker-compose-traefik.yml down

traefik-logs: ## Follow Traefik logs
	docker compose -f docker-compose-traefik.yml logs -f

# --- OpenClaw ---

openclaw-setup: ## Onboard OpenClaw (first-time setup)
	docker exec -it $(OPENCLAW_GATEWAY_CONTAINER) openclaw onboard

openclaw-config-setup: ## Interactive setup for openclaw.json from template
	@./scripts/setup-openclaw-config.sh

openclaw-cmd: ## Run OpenClaw CLI command (cmd="agents list")
	docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw $(cmd)

openclaw-devices-list: ## List connected OpenClaw devices
	docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices list

openclaw-devices-id: ## Extract request ID (easy to copy)
	@docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices list | grep -o '"requestId":"[^"]*"' | cut -d'"' -f4

openclaw-devices-approve: ## Approve OpenClaw device (requestId=<id>)
	docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices approve $(requestId)

openclaw-devices-auto-approve: ## Auto-extract and approve device
	@$(eval REQUEST_ID := $(shell docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices list 2>/dev/null | awk '/Pending \(1\)/{flag=1; next} /Paired \(/{flag=0} flag && /│/ && !/Request/' | head -1 | awk -F'│' '{print $$2}' | xargs))
	@if [ -z "$(REQUEST_ID)" ]; then \
		echo "✓ No pending device pairing requests"; \
		echo ""; \
		echo "To access the OpenClaw dashboard:"; \
		echo "  1. Get your gateway token: make openclaw-gateway-token"; \
		echo "  2. Open: http://$(PROJECT_NAME).openclaw.localhost"; \
		echo "  3. Enter the token in Control UI Settings (⚙️ icon)"; \
		echo "  4. Create device pairing and run this command again"; \
	else \
		echo "Approving device: $(REQUEST_ID)"; \
		docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices approve $(REQUEST_ID) && \
		echo "✓ Device approved successfully!"; \
	fi

openclaw-pair-watch: ## Watch and auto-approve device pairings (run this while setting up browser)
	@echo "👀 Watching for device pairing requests..."
	@echo "   Press Ctrl+C to stop"
	@echo ""
	@while true; do \
		REQUEST_ID=$$(docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices list 2>/dev/null | awk '/Pending \(1\)/{flag=1; next} /Paired \(/{flag=0} flag && /│/ && !/Request/' | head -1 | awk -F'│' '{print $$2}' | xargs); \
		if [ -n "$$REQUEST_ID" ]; then \
			echo "🔔 New pairing request detected: $$REQUEST_ID"; \
			docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices approve $$REQUEST_ID && \
			echo "✅ Device approved successfully!" && \
			echo "" && \
			echo "🎉 You can now access OpenClaw in your browser!" && \
			break; \
		fi; \
		sleep 2; \
	done

openclaw-pair-quick: ## Quick setup - shows token and waits for pairing
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "🚀 OpenClaw Quick Pairing Setup"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "📋 STEP 1: Copy this token"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@jq -r '.gateway.auth.token' .openclaw/openclaw.json 2>/dev/null || grep -A 2 '"auth"' .openclaw/openclaw.json | grep '"token"' | sed 's/.*"token": *"\([^"]*\)".*/\1/'
	@echo ""
	@echo "📋 STEP 2: Open this URL in your browser"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "http://$(PROJECT_NAME).openclaw.localhost"
	@echo ""
	@echo "📋 STEP 3: In the browser"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  1. Click the Settings (⚙️) icon"
	@echo "  2. Paste the token in 'Gateway Token' field"
	@echo "  3. Click 'Save' or press Enter"
	@echo ""
	@echo "👀 Waiting for pairing request..."
	@echo "   (This will auto-approve when you save the token)"
	@echo ""
	@while true; do \
		REQUEST_ID=$$(docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices list 2>/dev/null | awk '/Pending \(1\)/{flag=1; next} /Paired \(/{flag=0} flag && /│/ && !/Request/' | head -1 | awk -F'│' '{print $$2}' | xargs); \
		if [ -n "$$REQUEST_ID" ]; then \
			echo "🔔 Pairing request detected!"; \
			docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices approve $$REQUEST_ID && \
			echo "" && \
			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" && \
			echo "✅ SUCCESS! Device paired successfully!" && \
			echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" && \
			echo "" && \
			echo "🎉 Your browser is now connected to OpenClaw!" && \
			echo "   Refresh the page if you still see errors." && \
			echo "" && \
			break; \
		fi; \
		sleep 2; \
	done

openclaw-gateway-token: ## Show gateway auth token for browser login
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "🔑 Gateway Authentication Token"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@jq -r '.gateway.auth.token' .openclaw/openclaw.json 2>/dev/null || grep -A 2 '"auth"' .openclaw/openclaw.json | grep '"token"' | sed 's/.*"token": *"\([^"]*\)".*/\1/'
	@echo ""
	@echo "📋 How to use:"
	@echo "  1. Copy the token above"
	@echo "  2. Open: http://$(PROJECT_NAME).openclaw.localhost"
	@echo "  3. Click Settings (⚙️ icon) in the Control UI"
	@echo "  4. Paste the token in the 'Gateway Token' field"
	@echo "  5. Save and refresh the page"
	@echo ""

openclaw-pairing-list: ## List pending pairing requests
	docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw pairing list

openclaw-pairing-approve: ## Approve a pairing request (code=<code>)
	docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw pairing approve $(code)

openclaw-discord-token: ## Update Discord bot token (token=<new-token>)
	docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw config set channels.discord.token '"$(token)"' --json
	@echo "Discord token updated. Restarting gateway..."
	docker compose restart openclaw-gateway

openclaw-restart: ## Restart OpenClaw gateway
	docker compose restart openclaw-gateway

# --- Skills ---

install-skills: ## Install all OpenClaw skills from lock.json (Docker mode, requires: clawhub login)
	@echo "🔄 Installing skills from lock.json files..."
	@echo ""
	@echo "=== 1/6 Installing Shared Skills ==="
	@if [ -f .openclaw/.clawhub/lock.json ]; then \
		for skill in $$(cat .openclaw/.clawhub/lock.json | jq -r '.skills | keys[]'); do \
			version=$$(cat .openclaw/.clawhub/lock.json | jq -r ".skills.\"$$skill\".version"); \
			echo "  Installing $$skill@$$version..."; \
			docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw && npx clawhub install $$skill --version $$version --force" 2>/dev/null || echo "  ⚠️  Failed to install $$skill"; \
		done && \
		echo "✅ Shared skills installed"; \
	else \
		echo "⚠️  No shared skills lock file"; \
	fi
	@echo ""
	@echo "=== 2/6 Installing Owner Skills ==="
	@if [ -f .openclaw/workspace-owner/.clawhub/lock.json ]; then \
		for skill in $$(cat .openclaw/workspace-owner/.clawhub/lock.json | jq -r '.skills | keys[]'); do \
			version=$$(cat .openclaw/workspace-owner/.clawhub/lock.json | jq -r ".skills.\"$$skill\".version"); \
			echo "  Installing $$skill@$$version..."; \
			docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-owner && npx clawhub install $$skill --version $$version --force" 2>/dev/null || echo "  ⚠️  Failed to install $$skill"; \
		done && \
		echo "✅ Owner skills installed"; \
	else \
		echo "⚠️  No owner skills lock file"; \
	fi
	@echo ""
	@echo "=== 3/6 Installing Frontend Skills ==="
	@if [ -f .openclaw/workspace-frontend/.clawhub/lock.json ]; then \
		for skill in $$(cat .openclaw/workspace-frontend/.clawhub/lock.json | jq -r '.skills | keys[]'); do \
			version=$$(cat .openclaw/workspace-frontend/.clawhub/lock.json | jq -r ".skills.\"$$skill\".version"); \
			echo "  Installing $$skill@$$version..."; \
			docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-frontend && npx clawhub install $$skill --version $$version --force" 2>/dev/null || echo "  ⚠️  Failed to install $$skill"; \
		done && \
		echo "✅ Frontend skills installed"; \
	else \
		echo "⚠️  No frontend skills lock file"; \
	fi
	@echo ""
	@echo "=== 4/6 Installing Backend Skills ==="
	@if [ -f .openclaw/workspace-backend/.clawhub/lock.json ]; then \
		for skill in $$(cat .openclaw/workspace-backend/.clawhub/lock.json | jq -r '.skills | keys[]'); do \
			version=$$(cat .openclaw/workspace-backend/.clawhub/lock.json | jq -r ".skills.\"$$skill\".version"); \
			echo "  Installing $$skill@$$version..."; \
			docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-backend && npx clawhub install $$skill --version $$version --force" 2>/dev/null || echo "  ⚠️  Failed to install $$skill"; \
		done && \
		echo "✅ Backend skills installed"; \
	else \
		echo "⚠️  No backend skills lock file"; \
	fi
	@echo ""
	@echo "=== 5/6 Installing QA Lead Skills ==="
	@if [ -f .openclaw/workspace-qa-lead/.clawhub/lock.json ]; then \
		for skill in $$(cat .openclaw/workspace-qa-lead/.clawhub/lock.json | jq -r '.skills | keys[]'); do \
			version=$$(cat .openclaw/workspace-qa-lead/.clawhub/lock.json | jq -r ".skills.\"$$skill\".version"); \
			echo "  Installing $$skill@$$version..."; \
			docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-qa-lead && npx clawhub install $$skill --version $$version --force" 2>/dev/null || echo "  ⚠️  Failed to install $$skill"; \
		done && \
		echo "✅ QA Lead skills installed"; \
	else \
		echo "⚠️  No QA Lead skills lock file"; \
	fi
	@echo ""
	@echo "=== 6/6 Installing Tester Skills ==="
	@if [ -f .openclaw/workspace-tester/.clawhub/lock.json ]; then \
		for skill in $$(cat .openclaw/workspace-tester/.clawhub/lock.json | jq -r '.skills | keys[]'); do \
			version=$$(cat .openclaw/workspace-tester/.clawhub/lock.json | jq -r ".skills.\"$$skill\".version"); \
			echo "  Installing $$skill@$$version..."; \
			docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-tester && npx clawhub install $$skill --version $$version --force" 2>/dev/null || echo "  ⚠️  Failed to install $$skill"; \
		done && \
		echo "✅ Tester skills installed"; \
	else \
		echo "⚠️  No tester skills lock file"; \
	fi
	@echo ""
	@echo "🎉 All skills installed!"
	@echo "💡 Restart gateway: make openclaw-restart"


update-skills: ## Update all OpenClaw skills (Docker mode)
	@echo "🔄 Updating all skills (Docker mode)..."
	@echo ""
	@echo "=== Updating Skills (checking all workspaces) ==="
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw && npx clawhub update --all --force 2>/dev/null" && echo "✅ Shared skills updated" || echo "⚠️  No shared skills"
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-owner/skills && npx clawhub update --all --force 2>/dev/null" && echo "✅ Owner skills updated" || echo "⚠️  No owner skills"
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-frontend/skills && npx clawhub update --all --force 2>/dev/null" && echo "✅ Frontend skills updated" || echo "⚠️  No frontend skills"
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-backend/skills && npx clawhub update --all --force 2>/dev/null" && echo "✅ Backend skills updated" || echo "⚠️  No backend skills"
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-qa-lead/skills && npx clawhub update --all --force 2>/dev/null" && echo "✅ QA Lead skills updated" || echo "⚠️  No QA Lead skills"
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-tester/skills && npx clawhub update --all --force 2>/dev/null" && echo "✅ Tester skills updated" || echo "⚠️  No tester skills"
	@echo ""
	@echo "🎉 All skills updated!"
	@echo "💡 Restart gateway: make openclaw-restart"

# --- Template Management ---

init: ## Initialize project from template (interactive)
	@echo "🎯 OpenClaw 5-Agent Template Initialization"
	@echo ""
	@read -p "Project name (lowercase, hyphens only): " PROJECT_NAME && \
	 read -p "Git user name [$${PROJECT_NAME}-bot]: " GIT_USER_NAME && \
	 GIT_USER_NAME=$${GIT_USER_NAME:-$${PROJECT_NAME}-bot} && \
	 read -p "Git user email [bot@example.com]: " GIT_USER_EMAIL && \
	 GIT_USER_EMAIL=$${GIT_USER_EMAIL:-bot@example.com} && \
	 read -p "SSH port [2222]: " SSH_PORT && \
	 SSH_PORT=$${SSH_PORT:-2222} && \
	 read -sp "Dev user password: " DEV_USER_PASSWORD && echo "" && \
	 read -p "Anthropic API key: " ANTHROPIC_API_KEY && \
	 read -p "GitHub token (optional): " GITHUB_TOKEN && \
	 if ! echo "$$PROJECT_NAME" | grep -qE '^[a-z0-9-]+$$'; then \
	   echo "❌ Invalid project name. Use lowercase letters, numbers, hyphens only."; \
	   exit 1; \
	 fi && \
	 echo "PROJECT_NAME=$$PROJECT_NAME" > .env && \
	 echo "SSH_PORT=$$SSH_PORT" >> .env && \
	 echo "DEV_USER=dev" >> .env && \
	 echo "DEV_USER_PASSWORD=$$DEV_USER_PASSWORD" >> .env && \
	 echo "GIT_USER_NAME=$$GIT_USER_NAME" >> .env && \
	 echo "GIT_USER_EMAIL=$$GIT_USER_EMAIL" >> .env && \
	 echo "ANTHROPIC_API_KEY=$$ANTHROPIC_API_KEY" >> .env && \
	 echo "GITHUB_TOKEN=$$GITHUB_TOKEN" >> .env && \
	 if [ -f package.json ]; then \
	   sed -i '' "s/\"name\": \".*\"/\"name\": \"$$PROJECT_NAME\"/" package.json 2>/dev/null || \
	   sed -i "s/\"name\": \".*\"/\"name\": \"$$PROJECT_NAME\"/" package.json; \
	 fi && \
	 echo "" && \
	 echo "✅ Template initialized!" && \
	 echo "" && \
	 echo "Next steps:" && \
	 echo "  1. make traefik-start    # Once per machine" && \
	 echo "  2. make build && make start" && \
	 echo "  3. make dev-install" && \
	 echo "  4. Login to ClawHub: docker exec -it $$PROJECT_NAME-gateway npx clawhub login" && \
	 echo "  5. make install-skills" && \
	 echo "  6. Approve browser device" && \
	 echo "  7. Start coding!" && \
	 echo "" && \
	 echo "Access:" && \
	 echo "  Web UI:  http://$$PROJECT_NAME.openclaw.localhost" && \
	 echo "  IDE:     http://$$PROJECT_NAME.code.localhost" && \
	 echo "  SSH:     ssh -p $$SSH_PORT dev@localhost"

template-reset: ## Reset to template state (DANGER: deletes all project data)
	@echo "⚠️  This will DELETE all project-specific data!"
	@read -p "Type 'RESET' to continue: " confirm && [ "$$confirm" = "RESET" ]
	rm -rf .openclaw/identity/* .openclaw/agents/
	rm -rf .openclaw/workspace-*/.openclaw/workspace-state.json .openclaw/logs/
	rm -f .openclaw/openclaw.json.bak* backup.json
	mkdir -p .openclaw/identity .openclaw/devices
	cp .openclaw/openclaw.json.template .openclaw/openclaw.json
	echo '[]' > .openclaw/devices/paired.json
	echo '[]' > .openclaw/devices/pending.json
	@echo "✓ Reset to template state. Run 'make init' to configure."

verify-template: verify ## Alias for verify
verify: ## Verify template is ready for Git (checks for secrets in tracked files)
	@echo "🔍 OpenClaw Template Verification (Git-Aware)"
	@echo "=============================================="
	@echo ""
	@ERRORS=0; \
	if [ ! -d .git ]; then \
		echo "⚠️  Not a git repository. Initializing temporarily..."; \
		git init -q; \
		TEMP_GIT=true; \
	fi; \
	echo "Checking tracked files for secrets..."; \
	tracked_files=$$(git ls-files 2>/dev/null || git ls-files --others --exclude-standard 2>/dev/null); \
	for pattern in "MTQ4MzY1:Discord bot tokens" "b9ce5dde0c2b9f8c17bf5362ef46be2fa796cccfe9421e74:gateway auth tokens" "1317014410509684799:Discord guild IDs" "1483684870772359208\|1483684965429280920:Discord channel IDs" "967012508865032213:Discord user IDs"; do \
		IFS=':' read -r pat desc <<< "$$pattern"; \
		found=""; \
		for file in $$tracked_files; do \
			if [ -f "$$file" ] && [ "$$file" != "verify-template.sh" ] && [ "$$file" != "Makefile" ]; then \
				if grep -l "$$pat" "$$file" 2>/dev/null >/dev/null; then \
					found="$$found$$file\n"; \
				fi; \
			fi; \
		done; \
		if [ -n "$$found" ]; then \
			echo "❌ Found $$desc in files that WILL be committed:"; \
			echo -e "$$found" | sed 's/^/  /'; \
			ERRORS=$$((ERRORS + 1)); \
		else \
			echo "✅ No $$desc in tracked files"; \
		fi; \
	done; \
	echo ""; \
	echo "Checking required template files exist..."; \
	for file in ".openclaw/openclaw.json.template" ".gitignore" "README.md" "Makefile"; do \
		if [ -f "$$file" ]; then \
			echo "✅ $$file exists"; \
		else \
			echo "❌ $$file missing"; \
			ERRORS=$$((ERRORS + 1)); \
		fi; \
	done; \
	echo ""; \
	echo "Checking gitignore rules..."; \
	for rule in ".openclaw/openclaw.json" ".openclaw/agents/" ".openclaw/identity/" ".openclaw/devices/"; do \
		if grep -q "$$rule" .gitignore 2>/dev/null; then \
			echo "✅ .gitignore includes: $$rule"; \
		else \
			echo "❌ .gitignore missing: $$rule"; \
			ERRORS=$$((ERRORS + 1)); \
		fi; \
	done; \
	if [ "$$TEMP_GIT" = true ]; then \
		rm -rf .git; \
	fi; \
	echo ""; \
	echo "=============================================="; \
	if [ $$ERRORS -eq 0 ]; then \
		echo "✅ Template verification PASSED!"; \
		echo ""; \
		echo "Your template is secure and ready for GitHub."; \
		echo ""; \
		echo "Next steps:"; \
		echo "  1. git add ."; \
		echo "  2. git commit -m 'Initial commit: OpenClaw template'"; \
		echo "  3. git push origin master"; \
	else \
		echo "❌ Template verification FAILED with $$ERRORS error(s)"; \
		echo ""; \
		echo "Please fix the issues above before pushing to GitHub."; \
		exit 1; \
	fi

# --- Local OpenClaw Commands (no Docker) ---

gateway-start: ## Start OpenClaw gateway (Local mode)
	@echo "🚀 Starting OpenClaw gateway..."
	openclaw gateway start

gateway-stop: ## Stop OpenClaw gateway (Local mode)
	@echo "🛑 Stopping OpenClaw gateway..."
	openclaw gateway stop

gateway-restart: ## Restart OpenClaw gateway (Local mode)
	@echo "🔄 Restarting OpenClaw gateway..."
	openclaw gateway restart

gateway-status: ## Show OpenClaw gateway status (Local mode)
	@echo "📊 OpenClaw Gateway Status:"
	@openclaw gateway status || echo "❌ Gateway is not running"

agents-list: ## List all configured agents (Local mode)
	@echo "👥 Configured Agents:"
	@openclaw agents list

# --- Agent Tmux Sessions ---

tmux-setup: ## Setup tmux sessions for all agents
	@echo "🔧 Setting up agent tmux sessions in dev-server..."
	@docker compose exec -u $(DEV_USER) dev-server mkdir -p /home/$(DEV_USER)/logs
	@docker compose exec -u $(DEV_USER) dev-server bash -c 'for agent in frontend backend qa tester owner; do tmux new-session -d -s "agent-$$agent" -n "work" 2>/dev/null || echo "Session agent-$$agent already exists"; done'
	@echo "✅ Tmux sessions created for all agents"
	@echo ""
	@echo "📋 View agent activity:"
	@echo "  make tmux-watch agent=frontend"
	@echo "  make tmux-watch agent=backend"
	@echo "  make tmux-list"

tmux-watch: ## Watch agent tmux session (use: make tmux-watch agent=frontend)
	@if [ -z "$(agent)" ]; then \
		echo "❌ Please specify agent: make tmux-watch agent=frontend"; \
		exit 1; \
	fi
	@echo "👀 Attaching to agent-$(agent) tmux session..."
	@echo "   Press Ctrl+B then D to detach"
	@docker compose exec -u $(DEV_USER) dev-server tmux attach -t agent-$(agent)

tmux-list: ## List all agent tmux sessions
	@echo "📋 Active tmux sessions:"
	@docker compose exec -u $(DEV_USER) dev-server tmux ls 2>/dev/null || echo "No tmux sessions running. Run: make tmux-setup"

tmux-kill: ## Kill all agent tmux sessions
	@echo "🛑 Killing all agent tmux sessions..."
	@docker compose exec -u $(DEV_USER) dev-server bash -c 'for agent in frontend backend qa tester owner; do tmux kill-session -t "agent-$$agent" 2>/dev/null || true; done'
	@echo "✅ All agent sessions killed"

# --- Gateway Activity Tracking ---

gateway-logs: ## Show gateway container logs (live)
	@docker logs -f 0xthoth-gateway

gateway-logs-tail: ## Show last 50 lines of gateway logs
	@docker logs 0xthoth-gateway --tail 50

agent-sessions: ## List all agent session logs
	@echo "📋 Agent Session Logs:"
	@docker exec 0xthoth-gateway find /home/node/.openclaw/agents -name "*.jsonl" -type f 2>/dev/null | grep -v sessions.json | while read log; do \
		agent=$$(echo $$log | cut -d'/' -f6); \
		session=$$(basename $$log .jsonl); \
		lines=$$(docker exec 0xthoth-gateway sh -c "wc -l < $$log" 2>/dev/null || echo "0"); \
		echo "  📄 $$agent: $$session ($$lines messages)"; \
	done

agent-session-view: ## View agent session log (use: make agent-session-view agent=owner)
	@if [ -z "$(agent)" ]; then \
		echo "❌ Please specify agent: make agent-session-view agent=owner"; \
		exit 1; \
	fi
	@echo "📋 Latest session for $(agent):"
	@LATEST=$$(docker exec 0xthoth-gateway find /home/node/.openclaw/agents/$(agent)/sessions -name "*.jsonl" -type f 2>/dev/null | grep -v sessions.json | sort | tail -1); \
	if [ -z "$$LATEST" ]; then \
		echo "❌ No sessions found for $(agent)"; \
	else \
		echo "📂 $$LATEST"; \
		echo ""; \
		echo "Last 20 messages (use 'docker exec 0xthoth-gateway cat $$LATEST | jq' for full):"; \
		echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; \
		docker exec 0xthoth-gateway sh -c "tail -20 $$LATEST | jq -c '{type, role: .message.role, content_preview: (.message.content[0].type // \"unknown\")}' 2>/dev/null || tail -20 $$LATEST"; \
	fi

agent-watch-all: ## Watch both gateway and dev-server for an agent (split screen)
	@if [ -z "$(agent)" ]; then \
		echo "❌ Please specify agent: make agent-watch-all agent=frontend"; \
		exit 1; \
	fi
	@echo "🔍 Setting up split view for $(agent)..."
	@echo "  Left: Gateway logs"
	@echo "  Right: Dev-server tmux"
	@tmux new-session -d -s "watch-$(agent)" \; \
		send-keys "make gateway-logs" Enter \; \
		split-window -h \; \
		send-keys "make tmux-watch agent=$(agent)" Enter \; \
		attach-session -t "watch-$(agent)"
