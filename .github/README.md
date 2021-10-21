# dotfiles

These are my dotfiles. It is heavily inspired by <https://www.atlassian.com/git/tutorials/dotfiles>.
For posterity, some of that reference article will be repeated here.

## How it works

The trick is that we:

- treat our whole home directory as a repository (a bare one).
- alias git with our shell to `dfgit`. The alias also adds options to set where the bare
repository lives (`$HOME/.dotfile_config`) and to set the work tree path to `$HOME`.
- finally, for quality of life, we configure the repository to not show untracked files, which are
the majority of files that exist in a home directory. We only care about a specific few.

## Installing onto a new system

0. Install prerequisites

    - git (need for dotfiles)
    - zsh (needed for shell)

1. Clone and alias

    ```zsh
    git clone --bare git@github.com:t-mart/dotfiles.git $HOME/.dotfile_config
    alias dfgit='git --git-dir=$HOME/.dotfile_config/ --work-tree=$HOME'
    ```

    The last alias command is also in my zsh config, so that only needs to be done one.

2. Checkout out the dotfiles

    ```zsh
    dfgit checkout
    ```

    The step above might fail because the checkout might overwrite some existing files. Delete these
    or back them up somewhere. Rerun the command until it succeeds.

3. Don't show untracked files

    ```zsh
    dfgit config --local status.showUntrackedFiles no
    ```

## Changing dotfiles

Just treat the `dfgit` command like git and do your adds and commits like normal.

PRO TIP: If you are simply updating/deleting files git already knows about, use
`git commit -a -m <message>` to commit only changed files (not untracked files)

## Starting from scratch

*You won't need to run this unless you want to start a whole new repo! Just to remember...*

```zsh
git init --bare $HOME/.dotfile_config
alias dfgit='git --git-dir=$HOME/.dotfile_config/ --work-tree=$HOME'
dfgit config --local status.showUntrackedFiles no
```
