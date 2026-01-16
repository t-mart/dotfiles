#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.cargo/bin:$PATH"

# install binstall
if ! command -v cargo-binstall &> /dev/null; then
    echo "Installing cargo-binstall..."
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
fi

echo "Installing tree via cargo-binstall..."
cargo binstall --no-confirm --locked --git https://github.com/peteretelej/tree.git
