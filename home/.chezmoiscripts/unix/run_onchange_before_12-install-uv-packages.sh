#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

echo "Installing yt-dlp via uv..."
uv tool install yt-dlp --with mutagen --with curl_cffi --with yt-dlp-ejs
