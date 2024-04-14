# dotfiles

These are my dotfiles.

Managed with [Rotz](https://volllly.github.io/rotz/).

## Installation

1. Prerequisites:

   - Have `git` installed
   - Have `rotz` installed (e.g., `cargo install rotz`)

2. Clone and deploy:

   ```shell
   rotz clone git@github.com:t-mart/dotfiles.git
   ```

   *People that aren't me should use `https://github.com/t-mart/dotfiles.git`.*

3. For my nushell config to work, create a `~/profile.nu`, which can be empty.

   ```shell
   touch ~/profile.nu
   ```

   See [below](#profile.nu) for more details

4. (Windows only) Set environment variables:

   ```sh
   pwsh ~/.dotfiles/env-var-set.ps1
   ```

   (see [source](env-var-set.ps1) for details)

5. Link:

   ```sh
   rotz link
   ```

## Workflow

Rotz puts this repository in `~/.dotfiles`. It can be managed just like any
other git repository (e.g., `git pull`, `git push`, etc.).

## profile.nu

This file is for nushell configuration that is *not* source-controlled.
It is useful for things that are local to this user or this machine. Examples
include `PATH` modifications or any other environment variable.

Its name is modeled after the `~/.profile` file for bash.

This file is sourced by nushell on startup in `env.nu`. Due to nushell's
must-already-exist requirement for sourced files, it must be manually created
*before* nushell is run.

Here's an example of what the file may contain:

```nushell
use std "path add"

path add ~/.cargo/bin/
```
