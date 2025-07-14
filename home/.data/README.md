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

## `key.txt.age`

age-encrypted file containing the age key used by chezmoi to encrypt/decrypt
other files. This file is **passphrase encrypted** to protect the key itself.
See 1Password for the passphrase.

_While passphrase encrypting a private key file might seem like a strange
recursion, the file allows us to not need to enter the passphrase every time we
want to use the key._

Created by the following:

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

This is also documented in the
[chezmoi documentation](https://www.chezmoi.io/user-guide/frequently-asked-questions/encryption/).

After the `decrypt-private-key` script runs, the unencrypted key will be
available at `$HOME/.config/chezmoi/key.txt`.

## `packages.yaml`

See file for documentation.
