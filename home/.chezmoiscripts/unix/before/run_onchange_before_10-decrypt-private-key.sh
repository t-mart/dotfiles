#!/usr/bin/env bash
set -euo pipefail

readonly decrypted_key_file="${HOME}/.config/chezmoi/key.txt"
readonly encrypted_key_file="${CHEZMOI_WORKING_TREE}/data/key.txt.age"

if [[ -f "${decrypted_key_file}" ]]; then
  echo "Key file '${decrypted_key_file}' already exists. Skipping."
  exit 0
else
  mkdir -p "$(dirname "${decrypted_key_file}")"

  echo "Decrypting private age key to '${decrypted_key_file}'..."

  "${CHEZMOI_EXECUTABLE}" age decrypt --output "${decrypted_key_file}" --passphrase "${encrypted_key_file}"
  chmod 600 "${decrypted_key_file}"
  echo "Successfully decrypted and secured '${decrypted_key_file}'."
fi