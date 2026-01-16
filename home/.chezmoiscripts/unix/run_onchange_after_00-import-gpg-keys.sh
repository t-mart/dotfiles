#!/usr/bin/env bash
set -euo pipefail

"${CHEZMOI_EXECUTABLE}" decrypt home/.data/gpg-keys.txt.age | gpg --import --batch --yes

echo "GPG keys imported successfully."
