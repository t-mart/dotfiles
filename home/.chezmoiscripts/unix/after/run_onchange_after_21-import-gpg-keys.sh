#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_WORKING_TREE}/.chezmoiscripts/unix/common.sh"

log_banner "Importing personal GPG keys"

"${CHEZMOI_EXECUTABLE}" decrypt "${CHEZMOI_WORKING_TREE}/data/gpg-keys.txt.age" | gpg --import --batch --yes

log_info "GPG keys imported successfully."