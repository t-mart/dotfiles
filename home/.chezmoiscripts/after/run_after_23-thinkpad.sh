#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_SOURCE_DIR}/.chezmoiscripts/.common.sh"

# Link a config file to a system location and show setup instructions if needed
# Args: 
# - name: used in messages
# - target: the path of the target
# - link_path: the link to create
# - instructions_message: things to do next, shown if the link was updated
link_config() {
  local name=$1
  local target=$2
  local link=$3
  local instructions=$4

  local target
  target=$(realpath "${target}")
  
  if [[ ! -f "$target" ]]; then
    log_error "${name} config file not found at $target"
    exit 1
  fi
  
  if is_softlink_of "$link" "$target"; then
    log_info "${name} config link already correct."
  else
    log_info "Linking $link to ${target}..."
    sudo ln -sf "$target" "$link"
    gum confirm "$instructions"
  fi
}

if is_thinkpad_z13; then
  log_banner "Configuring ThinkPad Z13 specific settings"

  link_config \
    "thinkfan" \
    "${CHEZMOI_SOURCE_DIR}/dot_config/thinkfan.conf" \
    "/etc/thinkfan.conf" \
    "$(cat <<EOF
Next, you need to:

1. Run \`sensors-detect\`
2. Enable and start the thinkfan service

See https://wiki.archlinux.org/title/Fan_speed_control (especially the thinkfan section) for details.
EOF
)"

  link_config \
    "keyboard-backlightd" \
    "${CHEZMOI_SOURCE_DIR}/dot_config/keyboard-backlightd" \
    "/etc/conf.d/keyboard-backlightd" \
    "$(cat <<EOF
Next, you need to enable and start the keyboard-backlightd service.

See https://github.com/VorpalBlade/keyboard-backlightd for details.
EOF
)"
fi

