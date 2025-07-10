#!/usr/bin/env bash

if ! command -v uv &> /dev/null; then
    echo "uv is not installed. Installing now..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv is already installed. Skipping installation."
fi