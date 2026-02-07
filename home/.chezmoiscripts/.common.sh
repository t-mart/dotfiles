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

get_data_bool() {
    local value
    value=$("${CHEZMOI_EXECUTABLE}" execute-template "{{ .${1} }}" || echo "false")
    [[ "$value" == "true" ]]
}

is_workstation() {
    get_data_bool "isWorkstation"
}

is_graphical() {
    get_data_bool "isGraphical"
}

has_nvidia() {
    get_data_bool "hasNvidia"
}

uses_brother_printer() {
    get_data_bool "usesBrotherPrinter"
}

is_thinkpad_z13() {
    get_data_bool "isThinkpadZ13"
}

install_packagelist() {
    local list_file="${CHEZMOI_WORKING_TREE}/data/packagelists/${1}.yml"

    if [[ ! -f "$list_file" ]]; then
        echo "Packagelist file not found: $list_file"
        return
    fi

    log_info "Installing packages from '${list_file}' via paru..."
    
    # -r = raw output (no quotes)
    # '.[]' = iterate over the top-level list
    local packages
    packages=$(yq -r '.[]' "$list_file")

    # Pass the list to paru (no quotes around $packages to allow word splitting)
    # shellcheck disable=SC2086
    paru -S --needed $packages
}

# log the arguments to stderr. use `gum log` if available, otherwise just echo
log_info() {
    if command_exists gum; then
        gum log --level info "$@"
    else
        echo "INFO: $*" >&2
    fi
}

# log error messages to stderr. use `gum log` if available, otherwise just echo
log_error() {
    if command_exists gum; then
        gum log --level error "$@"
    else
        echo "ERROR: $*" >&2
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