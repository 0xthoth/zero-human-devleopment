#!/bin/bash
set -e

DEV_USER="${DEV_USER:-dev}"
HOME_DIR="/home/${DEV_USER}"

# --- SSH daemon ---
/usr/sbin/sshd

# --- Fix volume-mounted home ownership ---
# Remove stale sockets from previous runs before chown
find "${HOME_DIR}" -type s -delete 2>/dev/null || true
chown "${DEV_USER}:${DEV_USER}" "${HOME_DIR}"
for dir in .config .local .cache .ssh .openclaw-ssh; do
    mkdir -p "${HOME_DIR}/${dir}"
    chown -R "${DEV_USER}:${DEV_USER}" "${HOME_DIR}/${dir}"
done

# --- Auto-generate SSH keypair for OpenClaw (first run) ---
SSH_KEY="${HOME_DIR}/.openclaw-ssh/id_ed25519"
if [ ! -f "${SSH_KEY}" ]; then
    echo ">>> Generating SSH keypair for OpenClaw..."
    su - "${DEV_USER}" -c "ssh-keygen -t ed25519 -f '${SSH_KEY}' -N '' -q"
fi

# Ensure public key is in authorized_keys
mkdir -p "${HOME_DIR}/.ssh"
touch "${HOME_DIR}/.ssh/authorized_keys"
PUB_KEY=$(cat "${SSH_KEY}.pub" 2>/dev/null || true)
if [ -n "${PUB_KEY}" ] && ! grep -qF "${PUB_KEY}" "${HOME_DIR}/.ssh/authorized_keys"; then
    echo "${PUB_KEY}" >> "${HOME_DIR}/.ssh/authorized_keys"
fi
chmod 700 "${HOME_DIR}/.ssh"
chmod 600 "${HOME_DIR}/.ssh/authorized_keys"
chown -R "${DEV_USER}:${DEV_USER}" "${HOME_DIR}/.ssh"

# --- Seed code-server config (first run) ---
CS_CONFIG="${HOME_DIR}/.config/code-server/config.yaml"
if [ ! -f "${CS_CONFIG}" ]; then
    mkdir -p "$(dirname "${CS_CONFIG}")"
    cp /etc/code-server-config.yaml "${CS_CONFIG}"
    # Set password from env
    if [ -n "${CODE_SERVER_PASSWORD}" ]; then
        sed -i "s/^auth:.*/auth: password/" "${CS_CONFIG}"
        echo "password: ${CODE_SERVER_PASSWORD}" >> "${CS_CONFIG}"
    fi
    chown -R "${DEV_USER}:${DEV_USER}" "${HOME_DIR}/.config"
fi

# --- Seed .bashrc (first run) ---
if [ ! -f "${HOME_DIR}/.bashrc" ]; then
    cp /etc/skel/.bashrc "${HOME_DIR}/.bashrc"
    cat >> "${HOME_DIR}/.bashrc" << 'TMUX_PROMPT'

# --- Tmux session manager on login ---
if command -v tmux &>/dev/null && [ -z "$TMUX" ] && [ -t 0 ]; then
  SESSIONS=$(tmux list-sessions 2>/dev/null)
  echo ""
  echo "🖥️  Tmux Session Manager"
  echo "========================"

  if [ -n "$SESSIONS" ]; then
    echo ""
    echo "Active sessions:"
    echo "$SESSIONS" | nl -w2 -s") "
    echo ""
    echo "Options:"
    echo "  [number]  - Attach to session"
    echo "  [name]    - Create new session with this name"
    echo "  n         - Skip tmux"
    echo ""
    read -p "Choose: " REPLY

    case "$REPLY" in
      n|N) ;;
      [0-9]*)
        SESS=$(echo "$SESSIONS" | sed -n "${REPLY}p" | cut -d: -f1)
        if [ -n "$SESS" ]; then
          tmux attach -t "$SESS"
        else
          echo "Invalid number"
        fi
        ;;
      "")
        tmux attach
        ;;
      *)
        if tmux has-session -t "$REPLY" 2>/dev/null; then
          tmux attach -t "$REPLY"
        else
          echo "Creating session: $REPLY"
          tmux new-session -s "$REPLY" -c ~/project
        fi
        ;;
    esac
  else
    echo ""
    echo "No active sessions."
    echo ""
    echo "Options:"
    echo "  [name]  - Create session (e.g. feat-login, fix-bug)"
    echo "  Enter   - Create default 'dev' session"
    echo "  n       - Skip tmux"
    echo ""
    read -p "Session name: " REPLY

    case "$REPLY" in
      n|N) ;;
      "")  tmux new-session -s dev -c ~/project ;;
      *)   tmux new-session -s "$REPLY" -c ~/project ;;
    esac
  fi
fi
TMUX_PROMPT
    chown "${DEV_USER}:${DEV_USER}" "${HOME_DIR}/.bashrc"
fi

# --- Auto install dependencies on first run ---
if [ -f "${HOME_DIR}/project/pnpm-workspace.yaml" ] && [ ! -d "${HOME_DIR}/project/node_modules/.pnpm" ]; then
    echo ">>> First run: installing pnpm dependencies..."
    su - "${DEV_USER}" -c "cd ~/project && corepack enable 2>/dev/null; pnpm install --no-frozen-lockfile" || true
    echo ">>> Dependencies installed"
fi

# --- Create project symlink ---
if [ ! -e "${HOME_DIR}/projects" ] && [ -d "${HOME_DIR}/project" ]; then
    ln -sf "${HOME_DIR}/project" "${HOME_DIR}/projects"
    chown -h "${DEV_USER}:${DEV_USER}" "${HOME_DIR}/projects"
fi

# --- Start code-server ---
echo ">>> Starting code-server on :8080..."
su - "${DEV_USER}" -c "code-server --config '${CS_CONFIG}' &"

echo ">>> Dev server ready. SSH on :22, code-server on :8080"

# --- Start tmux "dev" session ---
su - "${DEV_USER}" -c "tmux new-session -d -s dev -c '${HOME_DIR}/project'" 2>/dev/null || true
echo ">>> tmux session 'dev' started (tmux attach -t dev)"

# Keep alive
tail -f /dev/null
