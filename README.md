# dotfiles

These are my dotfiles.

Managed with [chezmoi](https://www.chezmoi.io/).

## Deploy with one command

### Unix

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply t-mart
```

### Windows

Run in `powershell.exe` (not pwsh):
```
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -b ~/.local/bin -- init --apply t-mart"
```

## Update configuration on current host

```
chezmoi update
```