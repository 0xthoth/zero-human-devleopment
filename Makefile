-include .env
PROJECT_NAME ?= project
DEV_USER ?= dev
SSH_PORT ?= 2222
OPENCLAW_GATEWAY_CONTAINER ?= $(PROJECT_NAME)-gateway

.PHONY: help start stop restart build logs ssh \
        traefik-start traefik-stop traefik-logs \
        openclaw-setup openclaw-config-setup openclaw-cmd openclaw-devices-list openclaw-devices-id openclaw-devices-approve openclaw-devices-auto-approve \
        openclaw-discord-token openclaw-restart \
        update-password fix-data-permission dev-install \
        install-skills update-skills update-skills-local status init template-reset \
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
	@$(eval REQUEST_ID := $(shell docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices list 2>/dev/null | grep -o '"requestId":"[^"]*"' | cut -d'"' -f4))
	@if [ -z "$(REQUEST_ID)" ]; then \
		echo "✓ No pending device pairing requests"; \
		echo ""; \
		echo "To create a pairing request:"; \
		echo "  1. Open: http://$(PROJECT_NAME).openclaw.localhost"; \
		echo "  2. Click through the device pairing prompt"; \
		echo "  3. Run this command again to approve"; \
	else \
		echo "Approving device: $(REQUEST_ID)"; \
		docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices approve $(REQUEST_ID) && \
		echo "✓ Device approved successfully!"; \
	fi

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

install-skills: ## Install all OpenClaw skills (Docker mode, run after first start, requires: clawhub login)
	@echo "Installing shared skills..."
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install github-cli --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install github-ops --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install code-review --no-input
	@echo "Installing frontend skills..."
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install typescript --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install react-expert --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install react-best-practices --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install react-performance --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install tailwind-v4-shadcn --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install lb-tailwindcss-skill --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install lb-zod-skill --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install accessibility --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install sovereign-accessibility-auditor --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install testing-patterns --no-input
	@echo "Installing backend skills..."
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install nestjs --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install postgres-db --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install security-auditor --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install security-scanner --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install e2e-testing-patterns --no-input
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) npx clawhub install devops --no-input
	@echo "All skills installed!"

update-skills: ## Update all OpenClaw skills (Docker mode)
	@echo "🔄 Updating all skills (Docker mode)..."
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/skills && npx clawhub update --all"
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-owner/skills && npx clawhub update --all"
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-frontend/skills && npx clawhub update --all"
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-backend/skills && npx clawhub update --all"
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-qa-lead/skills && npx clawhub update --all"
	-docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/workspace-tester/skills && npx clawhub update --all"
	@echo "✅ All skills updated! Restart gateway: make openclaw-restart"

update-skills-local: ## Update all OpenClaw skills (Local mode, no Docker)
	@echo "🔄 Updating All Skills to Latest Versions (Local)..."
	@echo "📁 Project root: $(shell pwd)"
	@echo ""
	@echo "=== 1/6 Updating Shared Skills (all agents) ==="
	cd .openclaw/skills && clawhub update --all
	@echo "✅ Shared skills updated"
	@echo ""
	@echo "=== 2/6 Updating Owner Skills ==="
	cd .openclaw/workspace-owner/skills && clawhub update --all
	@echo "✅ Owner skills updated"
	@echo ""
	@echo "=== 3/6 Updating Frontend Skills ==="
	cd .openclaw/workspace-frontend/skills && clawhub update --all
	@echo "✅ Frontend skills updated"
	@echo ""
	@echo "=== 4/6 Updating Backend Skills ==="
	cd .openclaw/workspace-backend/skills && clawhub update --all
	@echo "✅ Backend skills updated"
	@echo ""
	@echo "=== 5/6 Updating QA Lead Skills ==="
	cd .openclaw/workspace-qa-lead/skills && clawhub update --all
	@echo "✅ QA Lead skills updated"
	@echo ""
	@echo "=== 6/6 Updating Tester Skills ==="
	cd .openclaw/workspace-tester/skills && clawhub update --all
	@echo "✅ Tester skills updated"
	@echo ""
	@echo "🎉 All skills updated to latest versions!"
	@echo ""
	@echo "Next step: Restart the gateway"
	@echo "  make gateway-restart"

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
