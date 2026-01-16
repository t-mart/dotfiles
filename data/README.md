# `.data/`

Files that chezmoi uses in some way, but are not directly managed by chezmoi.

## `gpg-keys.txt.age`

age-encrypted file containing public and/or private GPG keys used for signing
commits and other purposes.

Created by creating a file `gpg-keys.txt` containing the armored (public and/or
private) GPG keys, and then encrypting it with the command:

```bash
chezmoi gpg-keys.txt --output home/.data/gpg-keys.txt.age
```

See [key.txt.age](#keytxtage) for more details for the key to encrypt/decrypt
this file.

## `packages.yaml`

These dotfiles have a flexible mechanism for installing many types of packages.

Supported are:

- `apt` - Debian/Ubuntu package manager
- `winget` - Windows Package Manager
- `scoop` - Windows package manager for portable software
- `curl ... | sh` - Install via a shell script fetched with `curl`
- `irm ... | iex` - Install via a PowerShell script fetched with `irm`
- `cargo` - Rust package manager
- `uv` - Python package manager

See file for documentation.

## `key.txt.age`

Some of these dotfiles are encrypted with
[`age`](https://github.com/FiloSottile/age).

Chezmoi manages the encryption and decryption of these files, using a private
key file in this repository. This private key itself is passphrase-encrypted
(also with `age`). See 1Password for its value.

This process is explained at the
[chezmoi documentation](https://www.chezmoi.io/user-guide/frequently-asked-questions/encryption/).

## `windows.reg`

A registry file that contains some settings for Windows.

## `nilesoft-shell.nss`

Nilesoft Shell is a customizer for Windows' context menus. It is a _huge_
quality-of-life improvement.

Unfortunately, Shell's configuration is located in the directory into which it
is installed (in Program Files), so chezmoi cannot manage it directly. We
work-around this by creating a symlink.
