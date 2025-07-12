#!/usr/bin/env bash
set -euo pipefail

# Find the path to the nushell executable. Exit if not found.
readonly nu_path="$(which nu)" || { echo "nushell not found. Skipping set of it as default shell." >&2; exit 1; }

# If /etc/shells exists, add nushell to it if it's not already present.
if [ -f /etc/shells ]; then
  grep -qxF "$nu_path" /etc/shells || echo "$nu_path" | sudo tee -a /etc/shells >/dev/null
fi

# Change the current user's shell to nushell.
# This will likely prompt for your password.
echo "Changing default shell to nushell... (You may be prompted for your password.)"
chsh -s "$nu_path"

echo "Shell successfully set to nushell."
