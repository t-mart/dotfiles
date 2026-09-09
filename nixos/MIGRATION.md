# Migration sequence

This plan favors reversible steps. It moves the router and remote node last because recovery is harder.

Package and option names are directional. Verify each name against the pinned Nixpkgs revision before deployment.

## 1. Record facts

Record these facts before writing a host configuration:

- CPU architecture and firmware mode.
- Stable disk identifiers and current partition tables.
- Memory size and hibernation requirements.
- GPU, wireless, Bluetooth, and peripheral hardware.
- Network interfaces, addresses, routes, VLANs, and DNS behavior.
- Required listening ports and firewall paths.
- k3s server labels, taints, and storage paths.
- Data backup and restore procedures.
- Console or out-of-band recovery access.

Generate `hardware-configuration.nix` from the mounted target filesystems. Commit one generated file per host.

Do not copy a hardware file between hosts. Do not guess filesystem UUIDs or network interface names.

## 2. Create the flake

Create `flake.nix` with five named `nixosConfigurations` outputs. Pin the current stable release in `flake.lock`.

Add Home Manager, `sops-nix`, and Disko inputs. Make compatible inputs follow the primary Nixpkgs revision.

Add a formatter output and one build check per host. Keep the first shared modules small.

Build every host's system closure before any installation. Evaluate all hosts after each shared module change.

## 3. Define storage

Use GPT and UEFI on every machine that supports systemd-boot.

Use this default physical layout:

| Part | Size | Format | Mount |
| --- | --- | --- | --- |
| EFI system partition | 1 GiB | FAT32 | `/boot` |
| NixOS data | Remaining space | LUKS2, then Btrfs | Btrfs subvolumes |

Use LUKS2 on mobile systems and workstations. Decide remote-unlock requirements before encrypting headless hosts.

Use these Btrfs subvolumes as a starting point:

| Subvolume | Mount | Reason |
| --- | --- | --- |
| `@root` | `/` | Operating system state |
| `@home` | `/home` | User data and separate snapshots |
| `@nix` | `/nix` | Build data excluded from root snapshots |
| `@log` | `/var/log` | Logs retained across root recovery |
| `@swap` | `/swap` | Swap file excluded from snapshots |

Add a separate k3s data subvolume on `bayleaf` and `basil`. Mount it at the service's durable data path.

Enable Btrfs compression. Enable periodic trim for SSDs.

Do not snapshot the Nix store or the swap subvolume. Treat snapshots as recovery points, not backups.

Keep each Disko file beside its host. Use stable `/dev/disk/by-id` paths in destructive disk definitions.

Disko can erase its declared targets. Review the resolved device path before every destructive run.

### Swap policy

Enable zram swap on every host. Start with a maximum size near half of physical memory.

Give zram a higher priority than disk swap. Add disk swap for sustained pressure and emergency headroom.

Use these initial disk swap ranges:

| Host | Disk swap |
| --- | --- |
| `clove` | 8 to 16 GiB |
| `lemongrass` | 8 to 16 GiB without hibernation |
| `bayleaf` | 4 to 8 GiB |
| `basil` | 4 to 8 GiB |
| `mace` | 2 to 4 GiB |

For laptop hibernation, allocate swap for the worst observed image. A RAM-sized target plus margin is a safe starting point.

Use a dedicated swap partition if reliable hibernation matters. Btrfs swap files require extra resume-offset configuration.

Disable copy-on-write on a Btrfs swap file before its creation. Exclude its subvolume from snapshots.

Tune these values after observing memory pressure. Do not use swap as a substitute for k3s resource limits.

### `clove` exception

The current `clove` EFI partition is `/dev/sda1`, while its root is on `/dev/nvme0n1p2`.

Create a dedicated `clove` storage plan. Preserve the Windows EFI contents and verify its firmware boot entry.

Do not apply a default whole-disk Disko layout to either current disk.

## 4. Reproduce the base system

Create `base.nix` with boot, user, SSH, locale, time, Nix, logging, and administration settings.

Enable systemd-boot and retain several generations. Disable its interactive editor after recovery tests pass.

Move only the true headless package subset from `base.yml`. Move Docker to the hosts that run Docker workloads.

Create the `tim` account declaratively. Set Nushell as its shell after the package exists in the system closure.

Test SSH authentication before closing the installation console.

## 5. Reproduce each role

Implement roles in this order:

1. Build the KDE desktop and audio path.
2. Add development packages and user tools.
3. Add gaming support and host-specific graphics.
4. Add k3s with secrets and firewall rules.
5. Add router networking, Unbound, forwarding, and nftables.

Keep hardware settings in host files. Keep reusable service policy in role modules.

For `lemongrass`, port Thinkfan before enabling fan control. Verify each sensor and fan path on the running kernel.

For `keyboard-backlightd`, first check Nixpkgs. Otherwise, package a pinned source and define a hardened systemd service.

For `clove`, test the proprietary NVIDIA driver with Plasma Wayland and Steam before removing the old installation.

Both k3s hosts are standalone servers. Keep their internal cluster tokens separate.

## 6. Move home configuration

Import Home Manager as a NixOS module. Build Tim's home with each host's system generation.

Move one application from chezmoi at a time:

1. Add its Home Manager module or file declaration.
2. Build the target host.
3. Compare the generated configuration with the current file.
4. Activate the new generation.
5. Remove the matching chezmoi source.

Move Git, Nushell, Atuin, Kitty, and common terminal tools first. Move desktop-specific files after Plasma works.

Replace `uv tool install` with packaged tools when Nixpkgs provides them. Keep a temporary user command for unmatched tools.

Do not run chezmoi and Home Manager against the same destination path.

## 7. Move secrets

Create a `.sops.yaml` recipient policy. Give each host access only to its required secret files.

Create a distinct host age key during installation. Add an offline recovery recipient to every critical secret.

Migrate service credentials first. Test secret ownership and service ordering during `nixos-rebuild test`.

Restore personal GPG keys once from a trusted backup. Keep this action outside normal system activation.

Delete the old encrypted master-key workflow only after every encrypted chezmoi file has another owner.

## 8. Test before cutover

Run these checks from the NixOS repository:

```console
nix flake check
nix build .#nixosConfigurations.lemongrass.config.system.build.toplevel
sudo nixos-rebuild test --flake .#lemongrass
```

Replace `lemongrass` with each target hostname. Use `boot` before `switch` for risky remote network changes.

Check these items on every host:

- The system reaches the login or SSH target.
- The boot menu contains the previous generation.
- DNS, routes, and firewall rules match the host role.
- Required services start after reboot.
- Secrets have the correct owner and mode.
- Btrfs mounts and swap devices match the storage plan.
- Restore procedures can read the latest backup.

Use `nixos-rebuild test` for service changes. It does not make the tested generation the boot default.

## 9. Migration order

Use this order:

1. A local virtual machine for shared modules.
2. `lemongrass`, with local USB recovery available.
3. `clove`, after a verified Windows and EFI backup.
4. `bayleaf` and its standalone cluster.
5. `basil`, only with remote console access or a tested recovery path.
6. `mace`, after a replacement router can carry the network.

Move `mace` last. A router error can block every other recovery workflow.

Before each k3s reinstall, drain the node and verify replicated data. Restore cluster capacity before moving the next node.

Before `mace`, test its configuration with isolated LAN and WAN interfaces. Preserve a known-good router configuration outside the target disk.

## 10. Normal operation

Clone the same repository on every host. Keep each clone at a reviewed revision.

Run `nixos-rebuild switch --flake .` on the local host. The command selects `nixosConfigurations.<current-hostname>`.

For a remote host, build locally and target the explicit host attribute. Reboot remote infrastructure only during a recovery window.

Update `flake.lock` centrally. Build all five configurations before deployment.

Roll out shared changes in this order: laptop, desktop, local server, remote server, router.

## Completion criteria

The migration is complete when these statements are true:

- Every host boots a configuration from this flake.
- Every system service and privileged file comes from NixOS.
- Every runtime secret comes from `sops-nix` or an external secret provider.
- Home Manager owns all required home configuration.
- Flux owns all Kubernetes resources.
- Chezmoi performs no package, service, secret, or privileged-file work.
- Each host has a tested rollback and recovery path.
