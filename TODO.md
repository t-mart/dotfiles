# TODO

- [ ] get GPG keys from one password (and import them?)

- [ ] embrace winget. it has software that scoop doesn't, is better for
      self-upgrading software, and has access to microsoft store (windows
      terminal, vscode, etc). we can use **both** scoop and winget, but just
      make the right choice.

- [ ] 1password to get ssh keys, so i don't have to duplicate them here in this
      repo. will need to install 1password with scoop/winget first.

- [ ] go through packages.yaml and keep stuff i like, add stuff, etc

  - [ ] gate some packages with a prompt about "is this a headless install?"
        so we don't have to install things like vscode, mpv.net, etc.

- [ ] other cool things from <https://github.com/KapJI/dotfiles>

- [ ] review nushell. things have changed since i last configured it.

  - can use package manager to install plugins
  - autoload directory
  - fix broken path completion thing

- [ ] windows terminal settings (take out of `extra/` and make it a proper
      dotfile)

- [ ] Cascadia Mono font, jetbrains mono font, etc. make consistent for windows terminal and vscode-insiders.
