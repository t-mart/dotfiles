#!/usr/bin/env bash
set -euo pipefail

# If not arch, exit early.
if ! command -v makepkg >/dev/null 2>&1; then
    exit 0
fi

# Install paru (AUR helper)
if ! command -v paru >/dev/null 2>&1; then
    echo "Installing paru..."

    sudo pacman -Syu --noconfirm --needed base-devel git gnupg

    temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT # Ensures cleanup even on script failure

    git clone https://aur.archlinux.org/paru.git "$temp_dir/paru"
    (
        cd "$temp_dir/paru" || exit
        makepkg -si --noconfirm
    )

    echo "Paru installed successfully."
fi

# Install the base metapackage
echo "Installing 'tim-base' metapackage via paru..."
(
    cd "${CHEZMOI_WORKING_TREE}/data/arch-packages/tim-base" || exit
    paru -U --noconfirm
)

# Check if workstation packages should be installed
IS_WORKSTATION=$("${CHEZMOI_EXECUTABLE}" dump-config | jq -r '.data.isWorkstation' 2>/dev/null)
if [[ "$IS_WORKSTATION" == "true" ]]; then
    echo "Installing 'tim-workstation' metapackage via paru..."
    (
        cd "${CHEZMOI_WORKING_TREE}/data/arch-packages/tim-workstation" || exit
        paru -U --noconfirm
    )
fi
