#!/usr/bin/env bash
set -euo pipefail

# the path we expect from installation (this is correct for debian, ubuntu, and arch)
NU_PATH="/usr/bin/nu"
readonly NU_PATH

# Check if Nushell is installed ${NU_PATH} and is executable
if [ ! -x "$NU_PATH" ]; then
  echo "Nushell not found at $NU_PATH. Not setting default shell." >&2
  exit 0
fi

# If /etc/shells exists, add nushell to it if it's not already present
if [ -f /etc/shells ]; then
  # exact, full-line match
  if ! grep --quiet --line-regexp --fixed-strings "$NU_PATH" /etc/shells; then
    echo "Adding '$NU_PATH' to /etc/shells..." >&2
    echo "$NU_PATH" | sudo tee --append /etc/shells >/dev/null
  fi
fi

USERNAME="$(id -un)"

if [ -z "$USERNAME" ]; then
  echo "Error: Could not determine current username." >&2
  exit 1
fi

CURRENT_SHELL="$(getent passwd "$USERNAME" | cut --delimiter=: --fields=7)"
readonly CURRENT_SHELL

# If the user's shell is not $NU_PATH, run 'chsh'.
if [ "$CURRENT_SHELL" != "$NU_PATH" ]; then
  echo "Changing default shell for user '$USERNAME' to '$NU_PATH'..." >&2
  chsh -s "$NU_PATH"
  echo "Shell changed! Log out and back in for the change to take effect." >&2
fi
