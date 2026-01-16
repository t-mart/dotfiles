#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_WORKING_TREE}/.chezmoiscripts/unix/.common.sh"

log_banner "Setting default shell to Nushell"

# the path we expect from installation (this is correct for debian, ubuntu, and arch)
NU_PATH="/usr/bin/nu"
readonly NU_PATH

# Check if Nushell is installed ${NU_PATH} and is executable
if [ ! -x "$NU_PATH" ]; then
  log_info "Nushell not found at $NU_PATH. Not setting default shell."
  exit 0
fi

# If /etc/shells exists, add nushell to it if it's not already present
if [ -f /etc/shells ]; then
  # exact, full-line match
  if ! grep --quiet --line-regexp --fixed-strings "$NU_PATH" /etc/shells; then
    log_info "Adding '$NU_PATH' to /etc/shells..."
    echo "$NU_PATH" | sudo tee --append /etc/shells >/dev/null
  fi
fi

USERNAME="$(id -un)"
readonly USERNAME

if [ -z "$USERNAME" ]; then
  log_error "Could not determine current username."
  exit 1
fi

# iffy portability, but fine
CURRENT_SHELL="$(getent passwd "$USERNAME" | cut --delimiter=: --fields=7)"
readonly CURRENT_SHELL

# If the user's shell is not $NU_PATH, run 'chsh'.
if [ "$CURRENT_SHELL" != "$NU_PATH" ]; then
  log_info "Changing default shell for user '$USERNAME' to '$NU_PATH'..."
  chsh -s "$NU_PATH"
  log_info "Shell changed to ${NU_PATH}! Log out and back in for the change to take effect."
fi
