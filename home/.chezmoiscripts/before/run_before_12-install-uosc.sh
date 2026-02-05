#!/usr/bin/env bash
set -euo pipefail

# TODO: replace this with AUR mpv-uosc
# https://aur.archlinux.org/packages/mpv-uosc
# we need to do some symlinking it seems, which chezmoi can handle

source "${CHEZMOI_SOURCE_DIR}/.chezmoiscripts/.common.sh"

log_banner "Installing mpv uosc UI"

if ! is_graphical; then
    log_info "Not a workstation. Skipping mpv uosc UI installation."
    exit 0
elif [[ -d "${HOME}/.config/mpv/scripts/uosc" ]]; then
    log_info "mpv uosc UI already installed. Skipping."
    exit 0
fi

uosc_installer_url="https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh"

log_info "Downloading and running uosc installer from ${uosc_installer_url}..."
curl -fsSL "${uosc_installer_url}" | bash

log_info "mpv uosc UI installation complete."
