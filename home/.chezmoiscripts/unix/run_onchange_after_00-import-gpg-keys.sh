#!/usr/bin/env bash
set -euo pipefail

"${CHEZMOI_EXECUTABLE}" decrypt "${CHEZMOI_WORKING_TREE}/data/gpg-keys.txt.age" | gpg --import --batch --yes

echo "GPG keys imported successfully."
