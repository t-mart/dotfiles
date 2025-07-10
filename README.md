# dotfiles

These are my dotfiles.

Managed with [chezmoi](https://www.chezmoi.io/).

## Deploy with one command

### Unix

```bash
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

## `home/.data/key.txt.age`

This key is used by chezmoi to encrypt/decrypt other files. It is referenced by
the chezmoi config at `home/.chezmoi.toml.tmpl`.

It was created with the following commands:

```nushell
# first, create the key
age-keygen -o home/.data/key.txt
# take note of the public key in this file! it's used in the chezmoi config as the recipient.

# then, passphrase encrypt it
age -p -a home/.data/key.txt | save home/.data/key.txt.age
# save the passphrase in a secure place, like 1Password!

# then, delete the unencrypted key
rm home/.data/key.txt
```

Then, you can add encrypted things to chezmoi with:

```nushell
chezmoi add --encrypt ~/somefile.txt
```

While passphrase encrypting a private key file might seem like a strange
recursion, the file allows us to not need to enter the passphrase every time we
want to use the key.
