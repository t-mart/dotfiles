# dotfiles

These are my dotfiles.

## System deployment concepts

- Treat our whole home directory as a repository (a bare one).
- Alias git with our shell to `dfgit`. The alias also adds options to set where the bare
repository lives (`$HOME/.dotfile_config`) and to set the work tree path to `$HOME`.
- Finally, for quality of life, we configure the repository to not show untracked files, which are
the majority of files that exist in a home directory. We only care about a specific few.

This system is heavily inspired by <https://www.atlassian.com/git/tutorials/dotfiles>.

## Installing onto a new system

0. Install prerequisites

    - git (need for dotfiles)
    - zsh (needed for shell)

1. Clone and alias

    ```sh
    git clone --bare git@github.com:t-mart/dotfiles.git $HOME/.dotfile_config
    alias dfgit='git --git-dir=$HOME/.dotfile_config/ --work-tree=$HOME'
    ```

    (The alias command is in my shell startup files, so this is just a bootstrap until deployment.)

2. Checkout out the dotfiles

    ```sh
    dfgit checkout
    ```

    The step above might fail because the checkout might overwrite some existing files. Delete these
    or back them up somewhere. Rerun the command until it succeeds.

3. Don't show untracked files

    ```sh
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
