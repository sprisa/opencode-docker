#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${HOME}/.config/opencode" "${HOME}/workspace"
cd "${HOME}/workspace"

if [ -n "${OPENCODE_CORS_ORIGIN:-}" ]; then
  exec opencode serve --hostname 0.0.0.0 --port "${OPENCODE_PORT:-4096}" --cors "${OPENCODE_CORS_ORIGIN}"
fi
exec opencode serve --hostname 0.0.0.0 --port "${OPENCODE_PORT:-4096}"
