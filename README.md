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

## Testing

It has been invaluable to test how chezmoi applies changes to fresh machines.

For Windows, I use [VMware Workstation Pro](https://www.vmware.com/products/workstation-pro.html) with a Windows 11 VM. Importantly, I use a snapshot to revert the VM to start the next test.

For Linux, I use a simple docker container: `docker run -it --rm debian`

## Thanks

Thanks to [KapJI/dotfiles](https://github.com/KapJI/dotfiles) for inspiration and ideas.
