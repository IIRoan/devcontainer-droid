#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/devcontainer-features.env" ]; then
    # shellcheck disable=SC1091
    . "${SCRIPT_DIR}/devcontainer-features.env"
fi

log_info() {
    echo "[droid-cli] $*"
}

log_error() {
    echo "[droid-cli] ERROR: $*" >&2
}

USERNAME="${_REMOTE_USER:-"automatic"}"
if [ "${USERNAME}" = "root" ] || [ "${USERNAME}" = "automatic" ]; then
    KNOWN_USERS=("vscode" "node" "codespace" "ubuntu")
    for user in "${KNOWN_USERS[@]}"; do
        if id -u "${user}" >/dev/null 2>&1; then
            USERNAME="${user}"
            break
        fi
    done
fi
if [ -z "${USERNAME}" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME="root"
fi

USER_HOME="$(getent passwd "${USERNAME}" | cut -d: -f6)"
if [ -z "${USER_HOME}" ]; then
    USERNAME="root"
    USER_HOME="/root"
fi

ensure_packages() {
    if [ -f /usr/local/etc/vscode-dev-containers/common-debian.sh ]; then
        # shellcheck disable=SC1091
        . /usr/local/etc/vscode-dev-containers/common-debian.sh
        apt_get_update_if_needed
        check_packages curl ca-certificates grep coreutils
    else
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y --no-install-recommends curl ca-certificates grep coreutils
    fi
}

ensure_packages

INSTALL_SCRIPT_URL="https://app.factory.ai/cli"
INSTALLER_PATH="$(mktemp)"
trap 'rm -f "${INSTALLER_PATH}"' EXIT

log_info "Downloading upstream installer from ${INSTALL_SCRIPT_URL}"
curl -fsSL -o "${INSTALLER_PATH}" "${INSTALL_SCRIPT_URL}"
chmod 755 "${INSTALLER_PATH}"

log_info "Running upstream installer as ${USERNAME}"
if [ "${USERNAME}" = "root" ]; then
    sh "${INSTALLER_PATH}"
else
    if command -v sudo >/dev/null 2>&1; then
        sudo -H -u "${USERNAME}" sh "${INSTALLER_PATH}"
    else
        su - "${USERNAME}" -c "sh ${INSTALLER_PATH}"
    fi
fi

USER_LOCAL_BIN="${USER_HOME}/.local/bin"
FACTORY_HOME="${USER_HOME}/.factory"
FACTORY_BIN="${FACTORY_HOME}/bin"

DROID_BIN="${USER_LOCAL_BIN}/droid"
RG_BIN="${FACTORY_BIN}/rg"

if [ -x "${DROID_BIN}" ]; then
    log_info "Linking ${DROID_BIN} to /usr/local/bin/droid"
    ln -sf "${DROID_BIN}" /usr/local/bin/droid
else
    log_error "Expected Droid CLI at ${DROID_BIN}, but it was not found."
    exit 1
fi

if [ -x "${RG_BIN}" ]; then
    log_info "Linking ${RG_BIN} to /usr/local/bin/rg"
    ln -sf "${RG_BIN}" /usr/local/bin/rg
else
    log_error "Expected ripgrep at ${RG_BIN}, but it was not found."
    exit 1
fi

log_info "Droid CLI installation complete."
