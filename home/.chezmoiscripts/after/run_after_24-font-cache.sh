#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_SOURCE_DIR}/.chezmoiscripts/.common.sh"

if ! is_graphical; then
  exit 0
fi

log_banner "Rebuilding font cache"

if command_exists fc-cache; then
  fc-cache -fv
  log_info "Font cache rebuilt successfully."
else
  log_error "fc-cache command not found. Please install fontconfig to rebuild the font cache."
fi