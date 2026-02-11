# Package Lists

A package list defines a group of packages to install on Arch Linux during
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
optional `fingerprint` field specifies a GPG key to add to the keyring before
installation, a requirement for installing some packages.

Each package list file documents its specific purpose.
