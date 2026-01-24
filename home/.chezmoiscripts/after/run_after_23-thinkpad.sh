#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_SOURCE_DIR}/.chezmoiscripts/.common.sh"

if is_thinkpad_z13; then

  log_banner "Configuring ThinkPad Z13 specific settings"

  thinkfan_target="${CHEZMOI_SOURCE_DIR}/thinkfan.conf"
  thinkfan_link="/etc/thinkfan.conf"
  if is_softlink_of "$thinkfan_link" "$thinkfan_target"; then
    log_info "Thinkfan config link already correct."
  else
    log_info "Linking $thinkfan_link to thinkfan config..."
    sudo ln -sf "$thinkfan_target" "$thinkfan_link"
    gum confirm "$(cat <<EOF
Next, you need to:

1. Run \`sensors-detect\`
2. Enable and start the thinkfan service

See https://wiki.archlinux.org/title/Fan_speed_control (especially the thinkfan section) for details.
EOF
)"
  fi

  keyboard_backlightd_target="${CHEZMOI_SOURCE_DIR}/keyboard-backlightd"
  keyboard_backlightd_link="/etc/conf.d/keyboard-backlightd"
  if is_softlink_of "$keyboard_backlightd_link" "$keyboard_backlightd_target"; then
    log_info "keyboard-backlightd config link already correct."
  else
    log_info "Linking $keyboard_backlightd_link to keyboard-backlightd config..."
    sudo ln -sf "$keyboard_backlightd_target" "$keyboard_backlightd_link"
    gum confirm "$(cat <<EOF
Next, you need to enable and start the keyboard-backlightd service.

See https://github.com/VorpalBlade/keyboard-backlightd for details.
EOF
)"
  fi
fi

