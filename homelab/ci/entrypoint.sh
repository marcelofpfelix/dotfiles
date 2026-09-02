#!/bin/bash
set -eo pipefail

ANSIBLE_HOME="/home/ansible"
ANSIBLE_SSH_DIR="${ANSIBLE_HOME}/.ssh"

ensure_ssh_directory() {
    mkdir -p "${ANSIBLE_SSH_DIR}"
    chown ansible:ansible "${ANSIBLE_SSH_DIR}"
    chmod 700 "${ANSIBLE_SSH_DIR}"
}

set_file_permissions() {
    local file="$1"
    local mode="$2"

    if [ -e "$file" ]; then
        chown ansible:ansible "$file"
        chmod "$mode" "$file"
    fi
}

if [ "$(id -u)" != "0" ]; then
    cd /ansible
    exec "$@"
fi

if [ -d /tmp/ssh-keys ]; then
    echo "Setting up SSH keys..."
    ensure_ssh_directory

    cp -f /tmp/ssh-keys/* "${ANSIBLE_SSH_DIR}/" 2>/dev/null || true

    for key in "${ANSIBLE_SSH_DIR}"/id_*; do
        [ -f "$key" ] && ! [[ "$key" == *.pub ]] && set_file_permissions "$key" 600
    done

    for key in "${ANSIBLE_SSH_DIR}"/*.pub; do
        [ -f "$key" ] && set_file_permissions "$key" 644
    done

    set_file_permissions "${ANSIBLE_SSH_DIR}/known_hosts" 644
    set_file_permissions "${ANSIBLE_SSH_DIR}/config" 644
fi

if [ -n "${ANSIBLE_VAULT_PASSWORD:-}" ]; then
    echo "Setting up Ansible Vault password..."
    echo "${ANSIBLE_VAULT_PASSWORD}" > "${ANSIBLE_VAULT_PASSWORD_FILE}"
    set_file_permissions "${ANSIBLE_VAULT_PASSWORD_FILE}" 600
fi

if [ -n "${SCAN_SSH_HOSTS:-}" ]; then
    echo "Scanning and trusting SSH hosts: ${SCAN_SSH_HOSTS}"
    ensure_ssh_directory
    touch "${ANSIBLE_SSH_DIR}/known_hosts"
    set_file_permissions "${ANSIBLE_SSH_DIR}/known_hosts" 600

    echo "${SCAN_SSH_HOSTS}" | tr "," "\n" | while IFS= read -r host; do
        [ -n "$host" ] && echo "  - Scanning $host..." && \
            runuser -u ansible -- ssh-keyscan -H "$host" >> "${ANSIBLE_SSH_DIR}/known_hosts" 2>/dev/null
    done
fi

cd /ansible
exec runuser -u ansible -- "$@"
