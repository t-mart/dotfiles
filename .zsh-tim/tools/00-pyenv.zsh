PYENV_ROOT="$HOME/.pyenv"

if [ -d $PYENV_ROOT ]; then
    export PYENV_ROOT
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
fi
