#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_SOURCE_DIR}/.chezmoiscripts/.common.sh"

log_banner "Installing gum"

# If not arch, exit early.
if ! is_arch_linux; then
    log_info "Not on Arch Linux. Skipping gum installation."
    exit 0
fi

# Install gum, shell script UI tool
if ! command_exists gum; then
    log_info "Installing gum..."
    sudo pacman -Syu --noconfirm --needed gum
fi

