# dotfiles

These are my dotfiles.

Managed with [chezmoi](https://www.chezmoi.io/).

## Deploy with one command

### Unix

```bash
# apt update; apt install -y curl
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply t-mart
```

### Windows

Run in `powershell.exe` (not pwsh):

```powershell
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -b ~/.local/bin -- init --apply t-mart"
```

## Pull the latest changes from this repo and apply them

```bash
chezmoi update
```

## Thanks

Thanks to [KapJI/dotfiles](https://github.com/KapJI/dotfiles) for inspiration and ideas.
