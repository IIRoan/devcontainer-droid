#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if ! command -v devcontainer >/dev/null 2>&1; then
    cat <<'EOF' >&2
The Dev Containers CLI (devcontainer) is not installed.
Install it with: npm install -g @devcontainers/cli
After installation, re-run this script.
EOF
    exit 1
fi

devcontainer features test \
    --project-folder "${REPO_ROOT}" \
    --features droid-cli "$@"
