# dotfiles

These are my dotfiles.

## How it works

The basic idea is to:

- Use a _bare_ repository, which lets us put the usual `.git` directory somewhere else. If we used a
  _non-bare_ repository, git would create `$HOME/.git`, which would cause any git command run in a
  path under the home directory to erroneously believe it was in a repository (git commands traverse
  the file path hierarchy to find this directory).
- In our shell, alias `dfgit` to a specially-flavored invocation of git that is uses this bare
  repository.

This system is heavily inspired by <https://www.atlassian.com/git/tutorials/dotfiles>.

## Installing onto a new system

1. Install git (and private keys, etc)

2. Clone

   ```sh
   git clone --bare git@github.com:t-mart/dotfiles.git "$HOME/.dotfile_config"
   ```

3. Checkout out the dotfiles

   This gnarly command only needs to be used once on a fresh machine. After checkout, we'll use a
   shell alias.

   ```sh
   git --git-dir="$HOME/.dotfile_config/" --work-tree="$HOME" checkout
   ```

   **This step might fail** because the checkout might doesn't want to overwrite files that already
   exist. So, delete the ones listed or back them up somewhere. Rerun the command until it succeeds.

4. Windows-specific setup

   Some stuff that windows in particular needs:

   - Junction (like symlink) some files.This shoe-horns some applications into an XDG-like layout
     (i.e `~/.config`, etc).
   - Create the Windows-specific git config file

   To do all that, run the following in powershell:

   ```powershell

   # powershell
   New-Item -ItemType Junction -Path "$HOME\Documents\PowerShell" -Value "$HOME\.config\powershell\"

   # streamlink
   New-Item -ItemType Junction -Path "$HOME\AppData\Roaming\streamlink" -Value "$HOME\.config\streamlink\"

   # flameshot
   New-Item -ItemType Junction -Path "$HOME\AppData\Roaming\flameshot" -Value "$HOME\.config\flameshot\"

   # yt-dlp
   New-Item -ItemType Junction -Path "$HOME\AppData\Roaming\yt-dlp" -Value "$HOME\.config\yt-dlp\"

   # beets
   New-Item -ItemType Junction -Path "$HOME\AppData\Roaming\beets" -Value "$HOME\.config\beets\"

   # nushell
   New-Item -ItemType Junction -Path "$HOME\AppData\Roaming\nushell\" -Value "$HOME\.config\nushell\"

   # aria2
   New-Item -ItemType Junction -Path "$HOME\.aria2" -Value "$HOME\.config\aria2\"

   # scoop
   # scoop does portable installations that expect config somewhere relative to the
   # executable. the following junctions place those configs in the right scoop location
   New-Item -ItemType Junction -Path "$HOME\scoop\persist\mpv.net\portable_config" -Value "$HOME\.config\mpv.net\"
   New-Item -ItemType Junction -Path "$HOME\scoop\persist\mpv\portable_config" -Value "$HOME\.config\mpv\"

   # jpegview
   # this is installed with scoop and uses the `persist/` dir to store config. but, it doesn't seem
   # to work. jpegview doesn't seem to care about the persist dir -- you'd have to force the
   # application to look there, somehow. Instead, we place the settings in the user-override
   # location at `$env:APPDATA\jpegview`. ADDITIONALLY: it might be necessary to go into the
   # `scoop\apps\jpegview\current\JPEGView.ini` file and change
   #   StoreToEXEPath=true
   # to
   #   StoreToEXEPath=false
   New-Item -ItemType Junction -Path "$env:APPDATA\jpegview" -Value "$HOME\.config\jpegview\"

   # GPG program setting. Obviously, make sure to install gpg (with scoop) too.
   # see .config/git/config for more info
   "[gpg]`n  program = C:/Users/tim/scoop/apps/gpg/current/bin/gpg.exe`n" | Out-File -FilePath "$HOME\.config\git\windows"
   ```

   (This method could hypothetically be used on any platform to fix inconvenient config locations.)

5. Create a new shell

   So that way, the dotfiles take effect and load the `dfgit` alias of our various shells. `dfgit`
   can now be used for all interactions with the dotfile repository.

6. Hide untracked files

   This ensures that `dfgit status` doesn't show us a ton of files that we're not interested in.
   (Conversely, you will not be notified of a new file that you may want to commit, so remember to
   explicitly add them.)

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
`dfgit commit -a -m <message>` to commit only changed files (not untracked files)

## `dfgit` for New Shells

If configuring a new shell, an alias/mapping/function/etc should be configured so that running:

```sh
dfgit <...other args>
```

is the same as

```sh
git --git-dir="$HOME/.dotfile_config/" --work-tree="$HOME" <...other args>
```

Use your shells documentation to achieve that.

## Starting from scratch

_You won't need to run this unless you want to start a whole new repo! This is just to record how
this method is initialized._

```sh
git init --bare "$HOME/.dotfile_config"
```
