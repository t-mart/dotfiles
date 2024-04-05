# dotfiles

These are my dotfiles.

## How it works

The basic idea is to:

- Use a _bare_ repository, which lets us put the usual `.git` directory
  somewhere else. If we used a _non-bare_ repository, git would create
  `$HOME/.git`, which would cause any git command run in a path under the home
  directory to erroneously believe it was in a repository (git commands traverse
  the file path hierarchy to find this directory).
- In our shell, alias `dfgit` to a specially-flavored invocation of git that is
  uses this bare repository.

This system is heavily inspired by
<https://www.atlassian.com/git/tutorials/dotfiles>.

## Installing onto a new system

1. Install git (and private keys, etc)

2. Clone

   ```sh
   git clone --bare git@github.com:t-mart/dotfiles.git "$HOME/.dotfile_config"
   ```

3. Checkout out the dotfiles

   This command only needs to be used once on a fresh machine. After checkout,
   we'll use a shell alias.

   ```sh
   git --git-dir="$HOME/.dotfile_config/" --work-tree="$HOME" checkout
   ```

   **This step might fail** because the checkout might doesn't want to overwrite
   files that already exist. So, delete the ones listed or back them up
   somewhere. Rerun the command until it succeeds.

4. Windows-specific setup (optional)

   Some stuff that windows in particular needs:

   - Junction some files/directories. This lets us place config files for
     applications that wouldn't be looking to where this repository places them
     (for example, `.AppData`).
   - Create the Windows-specific git config file

   To do all that, run the following in powershell:

   ```powershell
   .\.config\link.ps1
   ```

5. Start a new shell (optional)

   Starting a new shell will load the new alias `dfgit`, if you have written it
   in your shell's configuration file (which you should check into this repo!).

   To write a new alias, see [dfgit for New Shells](#dfgit-for-new-shells).

6. Hide untracked files (optional)

   This ensures that `dfgit status` doesn't show us a ton of files that we're
   not interested in. (Conversely, you will not be notified of a new file that
   you may want to commit, so remember to explicitly add them.)

   ```sh
   dfgit config --local status.showUntrackedFiles no
   ```

## Adding/commiting/pushing/pulling/etc

Just pretend that `dfgit` = `git`, and interact like normal.

```sh
# examples
dfgit add .config/foo
dfgit commit -m "Add foo"
dfgit push
dfgit pull
```

PRO TIP: If you are simply updating/deleting files git already knows about, use
`dfgit commit -a -m <message>` to commit only changed files (not untracked
files)

## `dfgit` for New Shells

If configuring a new shell, an alias/mapping/function/etc should be configured
so that running:

```sh
dfgit <...other args>
```

is the same as

```sh
git --git-dir="$HOME/.dotfile_config/" --work-tree="$HOME" <...other args>
```

## Starting from scratch

_You won't need to run this unless you want to start a whole new repo! This is just to record how
this method is initialized._

```sh
git init --bare "$HOME/.dotfile_config"
```
