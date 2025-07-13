#!/usr/bin/env bash
set -euo pipefail

readonly encrypted_key_file="${CHEZMOI_SOURCE_DIR}/.data/gpg-keys.txt.age"

chezmoi decrypt "${encrypted_key_file}" | gpg --import

echo "GPG keys imported successfully."