# dotfiles

These are my dotfiles.

Managed with [Rotz](https://volllly.github.io/rotz/).

## Usage

1. Prerequisites:

   - Have `git` installed
   - Have `rotz` installed (e.g., `cargo install rotz`)

2. Clone and deploy:

   ```shell
   rotz clone
   ```

3. (Windows only) Set environment variables:

   ```sh
   pwsh ~/.dotfiles/env-var-set.ps1
   ```

   (see [source](env-var-set.ps1) for details)

4. Link:

   ```sh
   rotz link
   ```
