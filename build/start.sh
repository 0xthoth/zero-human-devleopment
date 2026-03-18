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
    chown "${DEV_USER}:${DEV_USER}" "${HOME_DIR}/.bashrc"
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
