#!/usr/bin/env bash
#
# Bootstrap the minimum tooling needed before chezmoi applies files, then
# decrypt the age private key that all subsequent scripts depend on.
set -euo pipefail

# ── uv ────────────────────────────────────────────────────────────────────────

if command -v uv &>/dev/null; then
    echo "INFO: uv already installed."
else
    echo "INFO: Installing uv via pacman..."
    sudo pacman -Syu --noconfirm --needed uv
fi

# ── age private key ───────────────────────────────────────────────────────────

readonly encrypted_key="${CHEZMOI_WORKING_TREE}/data/chezmoi-age-key.txt.age"
readonly decrypted_key="${HOME}/.config/chezmoi/key.txt"

if [[ -f "${decrypted_key}" ]]; then
    echo "INFO: Age key already exists at '${decrypted_key}'. Skipping."
else
    mkdir -p "$(dirname "${decrypted_key}")"
    echo "INFO: Enter your age passphrase (find it in 1Password under 'chezmoi')."
    "${CHEZMOI_EXECUTABLE}" age decrypt \
        --output "${decrypted_key}" \
        --passphrase \
        "${encrypted_key}"
    chmod 600 "${decrypted_key}"
    echo "INFO: Key decrypted to '${decrypted_key}'."
fi
