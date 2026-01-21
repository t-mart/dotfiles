# `data/`

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

## `key.txt.age`

Some of these dotfiles are encrypted with
[`age`](https://github.com/FiloSottile/age).

Chezmoi manages the encryption and decryption of these files, using a private
key file in this repository. This private key itself is passphrase-encrypted
(also with `age`). See 1Password for its value.

This process is explained at the
[chezmoi documentation](https://www.chezmoi.io/user-guide/frequently-asked-questions/encryption/).
