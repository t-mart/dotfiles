#!/usr/bin/env bash
set -euo pipefail

# This file must be prefixed with a `.` so that chezmoi does not try to run it
# directly. It is intended to be sourced by other scripts.

# a function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# a function to check if we're on arch linux. we proxy this to seeing if makepkg
# exists and pacman exists
is_arch_linux() {
    command_exists makepkg && command_exists pacman
}

is_workstation() {
    local value
    value=$("${CHEZMOI_EXECUTABLE}" execute-template '{{ .isWorkstation }}' || echo "false")
    [[ "$value" == "true" ]]
}

# log the arguments to stderr. use `gum log` if available, otherwise just echo
log_info() {
    if command_exists gum; then
        gum log --level info "$@"
    else
        echo "INFO: $@" >&2
    fi
}

# log error messages to stderr. use `gum log` if available, otherwise just echo
log_error() {
    if command_exists gum; then
        gum log --level error "$@"
    else
        echo "ERROR: $@" >&2
    fi
}

# write a more noticeable banner message with gum if available
log_banner() {
    if command_exists gum; then
        gum style --border normal --margin "1" --padding "1" --border-foreground 212 "$@"
    else
        echo "====================" >&2
        echo "$@" >&2
        echo "====================" >&2
    fi
}