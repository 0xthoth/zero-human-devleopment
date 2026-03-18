-include .env
PROJECT_NAME ?= project
DEV_USER ?= dev
SSH_PORT ?= 2222
OPENCLAW_GATEWAY_CONTAINER ?= $(PROJECT_NAME)-gateway

.PHONY: help start stop restart build logs ssh \
        traefik-start traefik-stop traefik-logs \
        openclaw-setup openclaw-cmd openclaw-devices-list openclaw-devices-approve \
        openclaw-discord-token openclaw-restart \
        update-password fix-data-permission dev-install \
        install-skills status init template-reset

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

openclaw-cmd: ## Run OpenClaw CLI command (cmd="agents list")
	docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw $(cmd)

openclaw-devices-list: ## List connected OpenClaw devices
	docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices list

openclaw-devices-approve: ## Approve OpenClaw device (requestId=<id>)
	docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices approve $(requestId)

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

install-skills: ## Install all OpenClaw skills (run after first start, requires: clawhub login)
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
