#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_SOURCE_DIR}/.chezmoiscripts/.common.sh"

log_banner "Installing uv packages"

export PATH="$HOME/.local/bin:$PATH"

log_info "Installing yt-dlp via uv..."
uv tool install yt-dlp --with mutagen --with curl_cffi --with yt-dlp-ejs
