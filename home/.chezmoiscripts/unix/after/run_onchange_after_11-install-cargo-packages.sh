#!/usr/bin/env bash
set -euo pipefail

source "${CHEZMOI_WORKING_TREE}/.chezmoiscripts/unix/common.sh"

log_banner "Installing cargo packages"

export PATH="$HOME/.cargo/bin:$PATH"

# install binstall
if ! command_exists cargo-binstall; then
    log_info "Installing cargo-binstall..."
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
fi

log_info "Installing rust_tree via cargo-binstall..."
cargo binstall --no-confirm --locked --git https://github.com/peteretelej/tree.git rust_tree
