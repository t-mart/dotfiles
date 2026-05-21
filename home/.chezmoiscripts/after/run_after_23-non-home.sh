#!/usr/bin/env bash
#
# Deploy /etc files. Chezmoi only cares about the home directory, so we need to
# do custom stuff for /etc. (Maybe we're outgrowing chezmoi?)
set -euo pipefail

source "${CHEZMOI_SOURCE_DIR}/.chezmoiscripts/.common.sh"

# Copy a config file to a system location and show setup instructions if needed
# Args:
# - name: used in messages
# - source: the path of the source file
# - dest: the destination path to copy to
# - instructions_message: things to do next, shown if the file was updated
copy_config() {
  local name=$1
  local source=$2
  local dest=$3
  local instructions=$4

  if [[ ! -f "$source" ]]; then
    log_error "${name} config file not found at $source"
    exit 1
  fi

  # Remove dangling symlinks so cp doesn't refuse to overwrite them
  if [[ -L "$dest" ]] && [[ ! -e "$dest" ]]; then
    sudo rm "$dest"
  fi

  if [[ -f "$dest" ]] && diff -q "$source" "$dest" &>/dev/null; then
    log_info "${name} config already up to date."
  else
    log_info "Copying $source to ${dest}..."
    sudo cp "$source" "$dest"
    gum confirm "$instructions"
  fi
}

log_banner "Deploying non-home files"

copy_config \
  "reflector" \
  "${CHEZMOI_WORKING_TREE}/data/non-home/reflector.conf" \
  "/etc/xdg/reflector/reflector.conf" \
  "$(cat <<EOF
Next, you need to enable and start the reflector service and timer.

See https://wiki.archlinux.org/title/Reflector for details.
EOF
)"

if is_thinkpad_z13; then
  copy_config \
    "thinkfan" \
    "${CHEZMOI_WORKING_TREE}/data/non-home/thinkfan.conf" \
    "/etc/thinkfan.conf" \
    "$(cat <<EOF
Next, you need to:

1. Run \`sensors-detect\`
2. Enable and start the thinkfan service

See https://wiki.archlinux.org/title/Fan_speed_control (especially the thinkfan section) for details.
EOF
)"

  copy_config \
    "keyboard-backlightd" \
    "${CHEZMOI_WORKING_TREE}/data/non-home/keyboard-backlightd" \
    "/etc/conf.d/keyboard-backlightd" \
    "$(cat <<EOF
Next, you need to enable and start the keyboard-backlightd service.

See https://github.com/VorpalBlade/keyboard-backlightd for details.
EOF
)"
fi

