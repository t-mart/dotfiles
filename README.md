# dotfiles

These are my dotfiles.

Managed with [chezmoi](https://www.chezmoi.io/).

## Deploy with one command

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply t-mart
```

## Common Tasks

- Pull and apply changes from remote repo

  ```bash
  chezmoi update --init --apply
  ```

- Add a new file to the repo

  ```bash
  chezmoi add ~/some/file
  ```

## Testing

It has been invaluable to test how chezmoi applies changes to fresh machines.

For Linux, build the Dockerfiles in the `tests/` directory and run them like this:

(**NOTE:** Use password `1234` for sudo access in the containers.)

- Arch Linux

  ```bash
  docker build -t chezmoi-arch -f tests/Dockerfile.archlinux .
  docker run --rm -it chezmoi-arch /bin/bash -c 'sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /home/tim/.local/bin init --apply t-mart'
  ```
