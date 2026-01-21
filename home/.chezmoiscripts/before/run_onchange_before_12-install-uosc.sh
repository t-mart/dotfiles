#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_SOURCE_DIR}/.chezmoiscripts/.common.sh"

if ! is_workstation; then
    log_info "Not a workstation. Skipping mpv uosc UI installation."
    exit 0
fi

log_banner "Installing mpv uosc UI"

uosc_installer_url="https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh"

log_info "Downloading and running uosc installer from ${uosc_installer_url}..."
curl -fsSL "${uosc_installer_url}" | bash

log_info "mpv uosc UI installation complete."