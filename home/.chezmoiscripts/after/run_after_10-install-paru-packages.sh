#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_SOURCE_DIR}/.chezmoiscripts/.common.sh"

log_banner "Installing paru and bootstrap packages"

# If not arch, exit early.
if ! is_arch_linux; then
    log_info "Not on Arch Linux. Skipping paru and package installation."
    exit 0
fi

# Install paru (AUR helper)
if ! command_exists paru; then
    log_info "Installing paru dependency packages..."
    sudo pacman -Syu --noconfirm --needed base-devel git gnupg

    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT # Ensures cleanup even on script failure

    log_info "Cloning and building paru from AUR..."
    git clone https://aur.archlinux.org/paru.git "$temp_dir/paru"
    (
        cd "$temp_dir/paru" || exit
        makepkg -si --noconfirm
    )

    log_info "Paru installed successfully."
fi

# Install yq for reading package lists
if ! command_exists yq; then
    log_info "Installing yq..."
    sudo pacman -Syu --noconfirm --needed yq
fi

install_packagelist "base"

if is_workstation; then
    install_packagelist "workstation"
fi

if is_graphical; then
    install_packagelist "graphical"
fi

if uses_brother_printer; then
    install_packagelist "brother-printer"
fi

if is_thinkpad_z13; then
    install_packagelist "thinkpad-z13"
fi