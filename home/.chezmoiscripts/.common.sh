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

has_pgp_key() {
    local key="$1"
    gpg --list-keys "$key" &> /dev/null
}

import_pgp_key() {
    local key="$1"
    gpg --receive-keys "$key"
}

install_packagelist() {
    local list_file="${CHEZMOI_WORKING_TREE}/data/packagelists/${1}.yml"

    if [[ ! -f "$list_file" ]]; then
        log_error "Packagelist file not found: $list_file"
        return 1
    fi

    log_info "Installing packages from '${list_file}' via paru..."

    local packages=()

    # Process in pairs
    # yq obviously can't provide a bash iteration flow for us, so we just
    # translate the package list to something that bash can easily read:
    #  name
    #  fingerprint (or empty if not set)
    #  name
    #  fingerprint
    #  ... and so on
    while IFS= read -r name && IFS= read -r fingerprint; do
        # If fingerprint exists and key is not present, prompt user
        if [[ -n "$fingerprint" ]] && ! has_pgp_key "$fingerprint"; then
            if gum confirm --negative "Skip" "Package '$name' requires PGP key '$fingerprint'. Import it?" < /dev/tty; then
                import_pgp_key "$fingerprint"
                packages+=("$name")
            fi
        else
            # No fingerprint or key already present - add package
            packages+=("$name")
        fi
    done < <(yq -r '.[] | .name, (.fingerprint // "")' "$list_file")

    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi

    # Install collected packages
    paru -S --needed "${packages[@]}"
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