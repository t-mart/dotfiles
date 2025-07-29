# dotfiles

These are my dotfiles.

Managed with [chezmoi](https://www.chezmoi.io/).

## Deploy with one command

*Note: This can take a while on the first run, as it installs many packages.*

### Unix

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply t-mart
```

### Windows

Run in `powershell.exe` (not pwsh):

```powershell
iex "&{$(irm 'https://get.chezmoi.io/ps1')} -b ~/.local/bin -- init --apply t-mart"
```

## Common Tasks

- Pull and apply changes from remote repo

  ```bash
  chezmoi update --init --apply
  ```

- Apply changes from local repo

  ```bash
  chezmoi apply --init
  ```

- Add a new file to the repo

  ```bash
  chezmoi add ~/some/file
  ```

## Testing

It has been invaluable to test how chezmoi applies changes to fresh machines.

For Windows, I use
[VMware Workstation Pro](https://www.vmware.com/products/workstation-pro.html)
with a Windows 11 VM. Importantly, I use a snapshot to revert the VM to a clean
state before the next test.

For Linux, build the Dockerfiles in the `tests/` directory and run them like this:

(**NOTE:** Use password `1234` for sudo access in the containers.)

- Arch Linux

  ```bash
  docker build -t chezmoi-arch -f tests/Dockerfile.archlinux .
  docker run --rm -it chezmoi-arch /bin/bash -c 'sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /home/tim/.local/bin init --apply t-mart'
  ```

- Debian

  ```bash
  docker build -t chezmoi-debian -f tests/Dockerfile.debian .
  docker run --rm -it chezmoi-debian /bin/bash -c 'sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /home/tim/.local/bin init --apply t-mart'
  ```

- Ubuntu

  ```bash
  docker build -t chezmoi-ubuntu -f tests/Dockerfile.ubuntu .
  docker run --rm -it chezmoi-ubuntu /bin/bash -c 'sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /home/tim/.local/bin init --apply t-mart'
  ```

## Features

- Flexible package installation for many package managers
- System setup for things like 1Password, shells, GPG keys, Windows registry,
  Windows Developer Mode, etc.

## Thanks

Thanks to [KapJI/dotfiles](https://github.com/KapJI/dotfiles) for inspiration
and ideas.
