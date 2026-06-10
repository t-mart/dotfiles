#!/usr/bin/env bash
#
# Bootstrap the minimum tooling needed to run Python scripts with uv.
set -euo pipefail

if ! command -v uv &>/dev/null; then
    echo "INFO: Installing uv via pacman..."
    sudo pacman -Syu --noconfirm --needed uv
fi
