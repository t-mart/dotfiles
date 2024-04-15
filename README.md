# dotfiles

These are my dotfiles.

Managed with [Rotz](https://volllly.github.io/rotz/).

## Installation

1. Prerequisites programs:

   - `git`
   - `rotz`

2. Clone and deploy:

   ```shell
   rotz clone git@github.com:t-mart/dotfiles.git
   ```

   *People that aren't me should use `https://github.com/t-mart/dotfiles.git`.*

3. For my nushell config to work, create a `~/profile.nu`, which can be empty.

   ```shell
   touch ~/profile.nu
   ```

   See relevant section in [env.nu](nushell/env.nu) for more details.

4. (Optional) Set "global" environment variables:

   To set environment variables permanently for programs (including those
   launched from the desktop environment), global environment variables should
   be set according to the operating system's methods.

   - Windows:

      ```sh
      pwsh ~/.dotfiles/env/windows.ps1
      ```

      (see [source](env/windows.ps1) for details)

   - Others

     Not yet implemented. On Ubuntu,
     [`~/.profile`](https://help.ubuntu.com/community/EnvironmentVariables#A.2BAH4-.2F.profile)
     would be a good place to put these.

5. Deploy (symlink):

   ```sh
   rotz link
   ```

## Workflow

Rotz puts this repository in `~/.dotfiles`. It can be managed just like any
other git repository (e.g., `git pull` or `git push`).
