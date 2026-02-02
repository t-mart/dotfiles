#!/bin/bash

# Prepend more paths for KDE-launched applications

GOPATH=$HOME/.local/share/go
export GOPATH

PATH="$GOPATH/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.deno/bin:$PATH"
export PATH
