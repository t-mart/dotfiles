# tools setup files

This directory is intended to hold files that setup command line tools, such as pyenv, nvm, etc.

## Gating

These dotfiles are portable to the many environments that I use. And not each environment is set up
the same way: different applications installed, different OSes, etc.

So, it's prudent to check that we should be setting up a given tool. To do that, check the
environment first like:

```zsh
PYENV_ROOT="$HOME/.pyenv"

if [ -d $PYENV_ROOT ]; then
    export PYENV_ROOT
    # ...
fi
```

## Precedence

The files in this directory are sourced in alphanumeric order (see `init.zsh`). We can leverage
this to create a precedence system if some tools depend on others.

The way we do it is by prefixing with a zero-padded two-digit number (and hyphen) in front of each
file name.

For example, if pip depends on pyenv, the names for those setup files might be:

```text
tools/
  00-pyenv.zsh
  10-pip.zsh
```
