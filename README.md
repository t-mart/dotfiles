# dotfiles

These are my dotfiles.

Managed with [chezmoi](https://www.chezmoi.io/).

## Installation

1. Prerequisites programs:

   - `chezmoi`

2. Clone and deploy:

   ```shell
   chezmoi init --apply t-mart
   ```

4. (Optional) Take a look in `extra/` for files that are may help setting up
   a new system. These files are not deployed to the system.

## XDG Variables

XDG variables should be set to the following values:

- `XDG_CACHE_HOME`: `<HOME_DIR>/.cache`
- `XDG_CONFIG_HOME`: `<HOME_DIR>/.config`
- `XDG_DATA_HOME`: `<HOME_DIR>/.local/share`
- `XDG_STATE_HOME`: `<HOME_DIR>/.local/state`

`<HOME_DIR>` should be replaced with the absolute path to the user's home
directory.
