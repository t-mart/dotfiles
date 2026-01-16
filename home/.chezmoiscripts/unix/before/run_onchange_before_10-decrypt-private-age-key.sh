#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_WORKING_TREE}/.chezmoiscripts/unix/.common.sh"

log_banner "Decrypting age private key"

readonly encrypted_key_file="${CHEZMOI_WORKING_TREE}/data/key.txt.age"
readonly decrypted_key_file="${HOME}/.config/chezmoi/key.txt"

if [[ -f "${decrypted_key_file}" ]]; then
  log_info "Key file '${decrypted_key_file}' already exists. Skipping."
  exit 0
else
  mkdir -p "$(dirname "${decrypted_key_file}")"

  log_info "The following prompt is for our age decryption passphrase. Find it in 1Password by searching for 'chezmoi'."

  "${CHEZMOI_EXECUTABLE}" age decrypt --output "${decrypted_key_file}" --passphrase "${encrypted_key_file}"
  chmod 600 "${decrypted_key_file}"
  log_info "Successfully decrypted '${decrypted_key_file}'."
fi