# NixOS migration design

This directory contains the initial NixOS repository and its migration notes.

Package and option names are directional. Verify each name against the pinned Nixpkgs revision before deployment.

## Configuration status

The flake composes all five hosts from shared NixOS and Home Manager modules.

Complete these replacement points before installation:

- Replace every `REPLACE_WITH_*_DISK` value with a stable disk identifier.
- Replace each generated `hardware-configuration.nix` stub with installer output.
- Add Tim's public SSH keys to `keys/tim.keys.nix`.
- Confirm each standalone k3s server's labels and network settings.
- Confirm `mace` interface names, addresses, and subnets.
- Create encrypted SOPS files and declare their runtime paths.
- Verify Arch package translations against Nixpkgs 26.05.

`clove` uses its recorded existing partition layout. Its storage file performs no Disko formatting.

No `flake.lock` exists yet because Nix is unavailable in the current environment.

Local inspection confirmed these `lemongrass` facts:

- It boots with UEFI on `x86_64`.
- It has an AMD Ryzen 5 PRO 7540U and integrated Radeon 740M graphics.
- It has a MediaTek MT7922 wireless adapter and a 512 GB WD SN740 NVMe disk.
- It has about 16 GB of memory and the expected ThinkPad keyboard-backlight LED.

The 16 GB disk swap target fits this memory size. Hibernation still requires resume configuration and a successful test.

## Decision

This project has outgrown chezmoi as a whole-machine manager.

Chezmoi still fits home file deployment. It does not fit the system responsibilities that this repository now gives it.

Current examples include:

- `run_after_setup.py` installs system packages and AUR packages.
- The same script changes the login shell and imports private GPG keys.
- `non-home.yaml` copies privileged files and starts system services.
- Prompt booleans approximate machine roles without naming a host.
- Package presence controls whether system configuration applies.
- The bootstrap must install `uv`, decrypt an age key, and then run more setup code.

These paths converge only part of the system state. They do not pin the complete package set or support system rollbacks.

Use NixOS for each operating system. Use Home Manager as a NixOS module for Tim's home configuration.

Keep chezmoi during migration. Remove it after Home Manager owns every required home file.

## Ownership boundaries

| Concern | Owner |
| --- | --- |
| Boot, filesystems, users, packages, networking, and services | NixOS |
| Shells, Git, terminal tools, and user configuration | Home Manager |
| Runtime secrets and service credentials | `sops-nix` |
| Fresh-install partition creation | Disko |
| Kubernetes objects and workloads | Flux |
| Temporary unmigrated dotfiles | chezmoi |

NixOS must own the k3s service and node configuration. Flux must own resources inside each cluster.

Do not make Flux responsible for the operating system. Do not put secret values directly into Nix expressions.

## Repository shape

Treat this directory as the repository root:

```text
.
|-- flake.nix
|-- flake.lock
|-- README.md
|-- MIGRATION.md
|-- hosts/
|   |-- basil/
|   |-- bayleaf/
|   |-- clove/
|   |-- lemongrass/
|   `-- mace/
|-- modules/
|   |-- nixos/
|   |   |-- base.nix
|   |   |-- desktop.nix
|   |   |-- development.nix
|   |   |-- gaming.nix
|   |   |-- k3s.nix
|   |   |-- laptop.nix
|   |   `-- router.nix
|   `-- home/
|       `-- tim.nix
|-- packages/
`-- secrets/
```

Each host directory contains these files:

- `default.nix` imports shared modules and defines host-specific values.
- `hardware-configuration.nix` contains generated hardware facts.
- `disko.nix` contains that host's destructive install layout.

Add a separate hardware module only when a host needs enough settings to justify one.

Do not create a generic host option framework first. Use plain module imports until repeated configuration becomes clear.

## Flake design

Pin NixOS 26.05 in `flake.lock`. Update one deliberate pull request at a time.

Use these initial inputs:

- `nixpkgs` from the `nixos-26.05` branch.
- Home Manager from its matching release branch.
- `sops-nix` for activation-time secrets.
- Disko for installation-time disk layout.

Make Home Manager and `sops-nix` follow the main `nixpkgs` input where supported.

Expose one `nixosConfigurations` attribute for each exact hostname:

```text
nixosConfigurations.basil
nixosConfigurations.bayleaf
nixosConfigurations.clove
nixosConfigurations.lemongrass
nixosConfigurations.mace
```

This structure lets every computer use one repository. `nixos-rebuild` selects the current hostname when the flake path omits `#host`.

Use an explicit host during installation or remote recovery. For example, use `.#lemongrass` from this directory.

Set `networking.hostName` in each host module. Keep the attribute name and hostname identical.

Commit `flake.lock`. Set each `system.stateVersion` once, using the release used for that host's first installation.

Set `home.stateVersion` with the same care. Do not change either value during normal upgrades.

## Shared modules

### `base.nix`

Apply this module to every host.

- Enable flakes and the modern Nix command.
- Configure the `tim` user, locale, time zone, SSH, and trusted Nix users.
- Enable firmware updates where the hardware supports them.
- Enable periodic store optimization and garbage collection.
- Configure journald limits and basic system monitoring.
- Install only useful headless administration tools.
- Enable systemd-boot through the shared boot settings.
- Enable zram swap with a higher priority than disk swap.

Do not move Docker into the base module. Enable a container runtime only on hosts that need it.

### `desktop.nix`

- Enable KDE Plasma with Wayland.
- Enable PipeWire, Bluetooth, printing, portals, and NetworkManager.
- Install the graphical package group from the current `graphical.yml` list.
- Configure fonts through NixOS or Home Manager.

### `development.nix`

- Install compilers, runtimes, media tools, and development command-line tools.
- Put user-facing command-line programs in Home Manager when no system service needs them.
- Keep system integrations, udev rules, and daemon packages in NixOS.
- Package the current `uv tool install` result declaratively where practical.

### `gaming.nix`

- Enable Steam and its required graphics support.
- Add compatibility tools only after a game needs them.
- Keep GPU configuration outside this module.

### `k3s.nix`

- Enable k3s through its NixOS service module.
- Run one standalone server with the default SQLite datastore.
- Keep `clusterInit` disabled because this is not an HA etcd cluster.
- Open the Kubernetes API, kubelet, and Flannel ports.
- Keep node labels and taints in host configuration.
- Keep cluster applications in Flux.

### `laptop.nix`

- Enable power, suspend, firmware, and laptop input support.
- Choose one power policy service to avoid conflicting controls.
- Enable periodic SSD trimming.

### `router.nix`

- Use `systemd-networkd` for stable interface configuration.
- Enable IPv4 and IPv6 forwarding explicitly.
- Configure nftables through NixOS modules and checked rulesets.
- Enable Unbound through its NixOS service module.
- Disable NetworkManager on this host.
- Keep interface names, subnets, DHCP, and upstream details in `hosts/mace`.

Validate the nftables rules before activation. Keep a local console available during every network change.

## Host composition

| Host | Imports | Host-specific work |
| --- | --- | --- |
| `bayleaf` | base, k3s | standalone cluster storage, node labels, and server networking |
| `basil` | base, k3s | remote-safe deployment, standalone cluster storage, and networking |
| `clove` | base, desktop, development, gaming | proprietary NVIDIA, dual boot, and printer support |
| `lemongrass` | base, desktop, development, gaming, laptop | AMD graphics, ThinkPad fan control, and keyboard backlight |
| `mace` | base, router | interfaces, forwarding, Unbound, nftables, and router services |

`bayleaf` and `basil` each run an independent, single-node cluster. Both use the k3s server role.

`clove` has `kubectl` and Flux client tools. Store the copied admin configurations in these files:

- `~/.kube/bayleaf.yaml`
- `~/.kube/basil.yaml`

Replace each kubeconfig server address with its reachable host address. Refresh each copy when K3s rotates its embedded client certificate.

Run `merge-kubeconfigs` after either source file changes. The command writes a merged `~/.kube/config` with unique identities.

Select either cluster through the standard context interface:

```console
kubectl --context bayleaf get nodes
kubectl --context basil get nodes
```

### `clove`

Enable unfree packages only where needed. Configure the proprietary NVIDIA driver in this host module.

Preserve the Windows installation and its EFI data. The current layout mounts `/dev/sda1` at `/boot`.

Do not let a generic Disko action format that partition. Prefer stable `/dev/disk/by-id` device paths during installation.

### `lemongrass`

Use the standard AMD graphics stack unless hardware detection requires an override.

Package `keyboard-backlightd` if Nixpkgs lacks it. Define its systemd unit and configuration in one module.

Port the existing `thinkfan.conf` after sensor path verification. Treat fan-control kernel options as host-specific settings.

### `mace`

Keep router configuration explicit and small. Avoid desktop or workstation imports.

Declare every accepted, forwarded, and translated traffic path. Use counters and logs during the first cutover.

### `bayleaf` and `basil`

Rebuild one k3s node at a time. Drain workloads before destructive installation when the cluster role requires it.

Store durable application data outside the root snapshot set. Back it up before each migration.

## Home Manager transition

Import Home Manager inside every NixOS configuration. Use the global Nixpkgs package set and user packages.

Translate the current files by responsibility:

- Use program modules for Git, Nushell, Atuin, Kitty, mpv, and supported tools.
- Use `xdg.configFile` and `home.file` for configurations without modules.
- Use `home.packages` for user command-line and graphical applications.
- Use NixOS packages for drivers, services, shells, and shared system tools.
- Keep the Nushell executable in `/etc/shells` through NixOS user configuration.

Migrate one program at a time. Remove its chezmoi source only after Home Manager produces the same result.

Avoid Home Manager activation scripts for system changes. A need for `sudo` means that NixOS owns the change.

## Secrets

Replace the repository's passphrase-encrypted master age key with per-host recipients.

- Give each host a distinct age identity.
- Keep only public recipients and encrypted SOPS documents in Git.
- Keep an offline recovery recipient in the password manager.
- Write runtime secrets under `/run/secrets` with narrow ownership and modes.
- Point services at secret files instead of interpolated secret values.
- Restore Tim's private GPG key as a deliberate user action.

Do not import a private GPG key during every system activation. Do not place secret text in the Nix store.

Useful initial secrets include private registry credentials, router credentials, and user application tokens.

## Package migration

Use the existing YAML lists as an inventory, not as a generated Nix input.

Translate `base.yml`, `graphical.yml`, `workstation.yml`, and `thinkpad-z13.yml` into their corresponding modules.

Some Arch names differ from Nixpkgs names. Some AUR packages require an overlay, a local package, or removal.

Start with required tools. Add convenience packages after each host boots and its core services work.

Prefer a stable NixOS base. Use an unstable package set only for isolated packages with a demonstrated need.

## Deferred work

Defer these features until every host runs a stable base configuration:

- Secure Boot through Lanzaboote.
- Impermanence or an ephemeral root.
- A remote deployment framework.
- A private binary cache.
- Broad custom module abstractions.

Native `nixos-rebuild` over SSH is enough for five hosts. Add deployment tooling only after repeated friction appears.

## References

- [NixOS system configuration](https://wiki.nixos.org/wiki/NixOS_system_configuration)
- [systemd-boot on NixOS](https://wiki.nixos.org/wiki/Systemd/boot)
- [Home Manager as a NixOS module](https://nix-community.github.io/home-manager/installation/nixos.html)
- [`sops-nix`](https://github.com/Mic92/sops-nix)
- [Disko](https://github.com/nix-community/disko)
