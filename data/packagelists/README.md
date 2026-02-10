# Package Lists

Package lists define which packages to install on Arch Linux during
`chezmoi apply`. During `chezmoi init`, configuration questions about the
machine determine which lists are enabled.

Schema example:

```yaml
# yaml-language-server: $schema=./.packagelist.schema.json

- name: "foo"
- name: "bar"
  fingerprint: "ABC123"
```

The `name` field specifies a package from the official repositories or AUR. The
optional `fingerprint` field adds the provided GPG key to the keyring before
installation (with user confirmation), a requirement for installing some
packages.

Each package list file documents its specific purpose.
