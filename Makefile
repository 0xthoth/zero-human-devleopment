-include .env
PROJECT_NAME ?= project
DEV_USER ?= dev
SSH_PORT ?= 2222
OPENCLAW_GATEWAY_CONTAINER ?= $(PROJECT_NAME)-gateway

.PHONY: help start stop restart build logs ssh status \
        traefik-start traefik-stop traefik-logs \
        openclaw-setup openclaw-config-setup openclaw-restart openclaw-gateway-token \
        openclaw-pair-quick openclaw-cmd agents-list \
        install-skills update-skills \
        tmux-list tmux-watch tmux-kill \
        init verify

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-28s\033[0m %s\n", $$1, $$2}'

# ============================================================
# Core
# ============================================================

start: ## Start project (dev-server + openclaw)
	@docker network inspect traefik_net >/dev/null 2>&1 || docker network create traefik_net
	docker compose up -d

stop: ## Stop project
	docker compose down

restart: ## Restart project
	docker compose restart

build: ## Rebuild dev-server image
	docker compose build --no-cache dev-server

logs: ## Follow project logs
	docker compose logs -f

status: ## Show project status + URLs
	@echo "Project: $(PROJECT_NAME)"
	@echo "---"
	@echo "Code-server: http://$(PROJECT_NAME).code.localhost"
	@echo "OpenClaw:    http://$(PROJECT_NAME).openclaw.localhost"
	@echo "SSH:         ssh $(DEV_USER)@127.0.0.1 -p $(SSH_PORT)"
	@echo "---"
	@docker compose ps

ssh: ## SSH into dev-server
	ssh $(DEV_USER)@127.0.0.1 -p $(SSH_PORT)

# ============================================================
# Traefik (shared reverse proxy — run once per machine)
# ============================================================

traefik-start: ## Start Traefik
	docker compose -f docker-compose-traefik.yml up -d

traefik-stop: ## Stop Traefik
	docker compose -f docker-compose-traefik.yml down

traefik-logs: ## Follow Traefik logs
	docker compose -f docker-compose-traefik.yml logs -f

# ============================================================
# OpenClaw
# ============================================================

openclaw-setup: ## First-time OpenClaw onboard
	docker exec -it $(OPENCLAW_GATEWAY_CONTAINER) openclaw onboard

openclaw-config-setup: ## Interactive openclaw.json setup from template
	@./scripts/setup-openclaw-config.sh

openclaw-restart: ## Restart OpenClaw gateway
	docker compose restart openclaw-gateway

openclaw-gateway-token: ## Show gateway auth token for browser login
	@jq -r '.gateway.auth.token' .openclaw/openclaw.json 2>/dev/null || echo "Config not found. Run: make openclaw-config-setup"

openclaw-pair-quick: ## Quick browser pairing (shows token + auto-approves)
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "🚀 OpenClaw Quick Pairing"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "1. Copy this token:"
	@jq -r '.gateway.auth.token' .openclaw/openclaw.json 2>/dev/null
	@echo ""
	@echo "2. Open: http://$(PROJECT_NAME).openclaw.localhost"
	@echo "3. Paste token in Settings (⚙️)"
	@echo ""
	@echo "👀 Waiting for pairing request..."
	@while true; do \
		REQUEST_ID=$$(docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices list 2>/dev/null | awk '/Pending \(1\)/{flag=1; next} /Paired \(/{flag=0} flag && /│/ && !/Request/' | head -1 | awk -F'│' '{print $$2}' | xargs); \
		if [ -n "$$REQUEST_ID" ]; then \
			docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw devices approve $$REQUEST_ID && \
			echo "✅ Paired!" && break; \
		fi; \
		sleep 2; \
	done

openclaw-cmd: ## Run OpenClaw CLI (usage: make openclaw-cmd cmd="agents list")
	docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw $(cmd)

agents-list: ## List configured agents
	@docker exec $(OPENCLAW_GATEWAY_CONTAINER) openclaw agents list 2>/dev/null || echo "Gateway not running"

# ============================================================
# Skills
# ============================================================

install-skills: ## Install all skills from lock.json files
	@echo "🔄 Installing skills..."
	@for ws in "" "workspace-owner" "workspace-frontend" "workspace-backend" "workspace-qa-lead" "workspace-tester"; do \
		LOCK=".openclaw/$${ws:+$$ws/}.clawhub/lock.json"; \
		if [ -f "$$LOCK" ]; then \
			LABEL=$${ws:-shared}; \
			echo "  $$LABEL:"; \
			for skill in $$(jq -r '.skills | keys[]' "$$LOCK" 2>/dev/null); do \
				version=$$(jq -r ".skills.\"$$skill\".version" "$$LOCK"); \
				echo "    $$skill@$$version"; \
				docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/$${ws:+$$ws} && npx clawhub install $$skill --version $$version --force" 2>/dev/null || echo "    ⚠️ failed"; \
			done; \
		fi; \
	done
	@echo "✅ Done! Run: make openclaw-restart"

update-skills: ## Update all skills to latest
	@echo "🔄 Updating skills..."
	@for ws in "" "workspace-owner" "workspace-frontend" "workspace-backend" "workspace-qa-lead" "workspace-tester"; do \
		docker exec $(OPENCLAW_GATEWAY_CONTAINER) bash -c "cd /home/node/.openclaw/$${ws:+$$ws} && npx clawhub update --all --force 2>/dev/null" || true; \
	done
	@echo "✅ Done! Run: make openclaw-restart"

# ============================================================
# Tmux (agent monitoring)
# ============================================================

tmux-list: ## List agent tmux sessions on dev-server
	@docker compose exec -u $(DEV_USER) dev-server tmux ls 2>/dev/null || echo "No sessions"

tmux-watch: ## Watch agent session (usage: make tmux-watch agent=frontend)
	@if [ -z "$(agent)" ]; then echo "Usage: make tmux-watch agent=frontend"; exit 1; fi
	docker compose exec -u $(DEV_USER) dev-server tmux attach -t agent-$(agent)

tmux-kill: ## Kill all agent tmux sessions
	@docker compose exec -u $(DEV_USER) dev-server bash -c 'tmux kill-server 2>/dev/null || true'
	@echo "✅ All sessions killed"

# ============================================================
# Setup
# ============================================================

init: ## Initialize project from template (interactive)
	@echo "🎯 OpenClaw 5-Agent Template Setup"
	@echo ""
	@read -p "Project name (lowercase, hyphens): " PROJECT_NAME && \
	 read -sp "Dev password: " DEV_USER_PASSWORD && echo "" && \
	 read -p "Anthropic API key: " ANTHROPIC_API_KEY && \
	 read -p "GitHub token (optional): " GITHUB_TOKEN && \
	 if ! echo "$$PROJECT_NAME" | grep -qE '^[a-z0-9-]+$$'; then \
	   echo "❌ Invalid name"; exit 1; \
	 fi && \
	 echo "PROJECT_NAME=$$PROJECT_NAME" > .env && \
	 echo "SSH_PORT=2222" >> .env && \
	 echo "DEV_USER=dev" >> .env && \
	 echo "DEV_USER_PASSWORD=$$DEV_USER_PASSWORD" >> .env && \
	 echo "GIT_USER_NAME=$$PROJECT_NAME-bot" >> .env && \
	 echo "GIT_USER_EMAIL=bot@example.com" >> .env && \
	 echo "ANTHROPIC_API_KEY=$$ANTHROPIC_API_KEY" >> .env && \
	 echo "GITHUB_TOKEN=$$GITHUB_TOKEN" >> .env && \
	 echo "" && \
	 echo "✅ Done! Next:" && \
	 echo "  1. make traefik-start" && \
	 echo "  2. make build && make start" && \
	 echo "  3. make openclaw-config-setup" && \
	 echo "  4. make openclaw-pair-quick" && \
	 echo "  5. make install-skills"

verify: ## Verify template (check for leaked secrets)
	@echo "🔍 Checking tracked files for secrets..."
	@ERRORS=0; \
	for pattern in "MTQ4MzY1:Discord tokens" "b9ce5dde:gateway tokens" "1317014410509684799:guild IDs"; do \
		IFS=':' read -r pat desc <<< "$$pattern"; \
		found=$$(git ls-files 2>/dev/null | xargs grep -l "$$pat" 2>/dev/null || true); \
		if [ -n "$$found" ]; then \
			echo "❌ $$desc found in: $$found"; ERRORS=$$((ERRORS + 1)); \
		else \
			echo "✅ No $$desc"; \
		fi; \
	done; \
	if [ $$ERRORS -eq 0 ]; then echo "✅ Clean!"; else echo "❌ Fix above issues"; exit 1; fi
