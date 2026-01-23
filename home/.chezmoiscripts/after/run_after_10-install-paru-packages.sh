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

# Add GPG keys for certain packages
# Admittedly, this is a lot of code for something small.
PACKAGE_GPG_KEYS=(
    "1password-cli"  "3FEF9748469ADBE15DA7CA80AC2D62742012EA22"
    "gallery-dl-bin" "5680CA389D365A88"
)

MISSING_CSV="Package,GPG Key ID"
MISSING_COUNT=0
for ((i=0; i<${#PACKAGE_GPG_KEYS[@]}; i+=2)); do
    pkg="${PACKAGE_GPG_KEYS[i]}"
    key="${PACKAGE_GPG_KEYS[i+1]}"

    # Check for key existence
    if ! gpg --list-keys "$key" &> /dev/null; then
        MISSING_CSV+=$'\n'"$pkg,$key"
        MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
done

if (( MISSING_COUNT > 0 )); then
    log_info "Need the following GPG keys to install some packages:"
    echo "$MISSING_CSV" | gum table --print
    if gum confirm "Proceed to fetch missing GPG keys?"; then
        while IFS=, read -r pkg key; do
            log_info ":: Importing $pkg..."
            gpg --receive-keys "$key" || log_error "!! Failed to import $key"
        done < <(echo "$MISSING_CSV" | tail -n +2)
    fi
fi

install_packagelist "base"

if is_workstation; then
    install_packagelist "workstation"
fi

if is_graphical; then
    install_packagelist "graphical"
fi