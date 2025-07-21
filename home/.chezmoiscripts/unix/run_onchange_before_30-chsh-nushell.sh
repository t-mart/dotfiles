#!/usr/bin/env bash
set -euo pipefail

# the path we expect from apt installation (via nushell sources set earlier in chezmoi)
readonly NU_PATH="/usr/bin/nu"

# Check if Nushell is installed ${NU_PATH} and is executable
if [ ! -x "$NU_PATH" ]; then
  echo "Nushell not found at $NU_PATH. Not setting default shell." >&2
  exit 1
fi

readonly ELEVATE_PREFIX=$([ "$EUID" -ne 0 ] && echo "sudo")

# If /etc/shells exists, add nushell to it if it's not already present
if [ -f /etc/shells ]; then
  # exact, full-line match
  if ! grep --quiet --line-regexp --fixed-strings "$NU_PATH" /etc/shells; then
    echo "Adding '$NU_PATH' to /etc/shells..." >&2
    echo "$NU_PATH" | $ELEVATE_PREFIX tee --append /etc/shells >/dev/null
  fi
fi

if [ -z "$USER" ]; then
  echo "Error: \$USER environment variable is not set. Cannot determine current user." >&2
  exit 1
fi

readonly current_shell="$(getent passwd "$USER" | cut --delimiter=: --fields=7)"

# If the user's shell is not $NU_PATH, run 'chsh'.
if [ "$current_shell" != "$NU_PATH" ]; then
  echo "Changing default shell for user '$USER' to '$NU_PATH'..." >&2
  chsh -s "$NU_PATH"
  echo "Shell changed! Log out and back in for the change to take effect." >&2
fi
