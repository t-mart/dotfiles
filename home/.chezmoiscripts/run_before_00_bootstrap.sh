#!/usr/bin/env bash
#
# Bootstrap the minimum tooling needed to run Python scripts with uv.
set -euo pipefail

if ! command -v uv &>/dev/null; then
    if ! command -v pacman &>/dev/null; then
        echo "ERROR: pacman not found; this setup expects an Arch-based system." >&2
        exit 1
    fi

    # pacman needs root. If we're already root (e.g. install ISO, container),
    # call it directly; otherwise escalate with sudo, which must be present.
    sudo=()
    if [[ $EUID -ne 0 ]]; then
        if ! command -v sudo &>/dev/null; then
            echo "ERROR: not running as root and sudo not found; cannot install uv." >&2
            exit 1
        fi
        sudo=(sudo)
    fi

    echo "INFO: Installing uv via pacman..."
    "${sudo[@]}" pacman -Syu --noconfirm --needed uv
fi
