# dotfiles

These are my dotfiles.

## System deployment concepts

The basic idea is to:

- Designate our whole home directory as a *bare* repository, which allows us to place the typical
  `.git` directory in a custom spot (`$HOME/.dotfile_config`). Inside this bare repository, we
  selectively choose which files are version-controlled and ignore those that are not.
- Alias `dfgit` to a specially-flavored invocation of git that is aware of this bare repository.

This system is heavily inspired by <https://www.atlassian.com/git/tutorials/dotfiles>.

## Installing onto a new system

0. Install git

1. Clone

    ```sh
    git clone --bare git@github.com:t-mart/dotfiles.git $HOME/.dotfile_config
    ```

2. Bootstrap `dfgit`

    We need to perform an initial checkout of this repository with a custom
    invocation of git. This is just to bootstrap our current session. Later,
    this alias/function will be present in our shell startup files.

    - If on Linux-ish, do this:

        ```sh
        # LINUX ONLY
        alias dfgit='git --git-dir=$HOME/.dotfile_config/ --work-tree=$HOME'
        ```

    - Or on Windows, do this:

        ```powershell
        # WINDOWS/POWERSHELL ONLY
        function dfgit {
            git --git-dir=$HOME/.dotfile_config/ --work-tree=$HOME $args
        }
        ```

3. Checkout out the dotfiles

    ```sh
    dfgit checkout
    ```

    **This step might fail** because the checkout might doesn't want to overwrite files that already
    exist. So, delete the ones listed or back them up somewhere. Rerun the command until it
    succeeds.

4. Don't show untracked files

    This ensures that `git status` doesn't show us a ton of files that we're not interested in.
    (Conversely, you will not be notified of a new file that you may want to commit, so remember
    to explicitly add them.)

    ```sh
    dfgit config --local status.showUntrackedFiles no
    ```

5. (Windows only) Set up junctions

    To sorta "symlink" some files on Windows, create Junctions. This shoe-horns some applications
    into an XDG-like layout (i.e `~/.config`, etc).

    ```powershell
    # Get home
    cd ~

    # powershell
    New-Item -ItemType Junction -Path "Documents\PowerShell" -Value ".config\powershell\"

    # streamlink
    New-Item -ItemType Junction -Path "AppData\Roaming\streamlink" -Value ".config\streamlink\"

    # flameshot
    New-Item -ItemType Junction -Path "AppData\Roaming\flameshot" -Value ".config\flameshot\"

    # yt-dlp
    New-Item -ItemType Junction -Path "AppData\Roaming\yt-dlp" -Value ".config\yt-dlp\"

    # beets
    New-Item -ItemType Junction -Path "AppData\Roaming\beets" -Value ".config\beets\"

    # scoop
    # scoop does portable installations that expect config somewhere relative to the
    # executable. the following junctions place those configs in the right scoop location
    New-Item -ItemType Junction -Path "scoop\persist\mpv.net\portable_config" -Value ".config\mpv.net\"
    New-Item -ItemType Junction -Path "scoop\persist\mpv\portable_config" -Value ".config\mpv\"
    New-Item -ItemType Junction -Path "scoop\persist\jpegview" -Value ".config\jpegview\"
    ```

## Changing dotfiles

Just pretend that `dfgit` = `git`, and do your adds and commits like normal.

```sh
# examples
dfgit add .config/foo
dfgit commit -m "Add new config file foo"
dfgit push
dfgit pull
```

PRO TIP: If you are simply updating/deleting files git already knows about, use
`git commit -a -m <message>` to commit only changed files (not untracked files)

## Starting from scratch

*You won't need to run this unless you want to start a whole new repo! This is just to record how
this method is initialized.*

```zsh
git init --bare $HOME/.dotfile_config
alias dfgit='git --git-dir=$HOME/.dotfile_config/ --work-tree=$HOME'
dfgit config --local status.showUntrackedFiles no
```
