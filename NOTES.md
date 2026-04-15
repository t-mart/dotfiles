# Notes

## Stop templating scripts

Chezmoi offers the execution of scripts during runs. (I use this to do package
management which is maybe an abuse of chezmoi, but its convenient).

To avoid making franken-scripts that use Go templating on top of bash, a cleaner
pattern seems to be to write in pure bash, and just query `chezmoi` for the
information needed.

`chezmoi` can be found absolutely at the `CHEZMOI_EXECUTABLE` environment
variable.

## clove partitioning and EFI stuff

For lack of a better place, here's some stuff about my main computer `clove` and
its EFI setup.

Partition layout:

```
TARGET      SOURCE                  FSTYPE
/           /dev/nvme0n1p2[/@]      btrfs 
├─/home     /dev/nvme0n1p2[/@home]  btrfs 
├─/swap     /dev/nvme0n1p2[/@swap]  btrfs 
├─/var/log  /dev/nvme0n1p2[/@log]   btrfs 
└─/boot     /dev/sda1               vfat  
```

The following is how you might mount the partitions `clove` uses in a USB live
session when installing/repairing the system.

- Root partition is `/dev/nvme0n1p2`. This is btrfs. The root subvolume is `@`.
  To mount this:

  ```bash
  mount -o subvol=@ /dev/nvme0n1p2 /mnt
  ```

- (Optional) Home partition is also on `/dev/nvme0n1p2`, but under subvolume
  `@home`. To mount this:

  ```bash
  mount -o subvol=@home /dev/nvme0n1p2 /mnt/home
  ```

- EFI partition is `/dev/sda1`. This is FAT32. To mount this:

  ```bash
  mount --mkdir /dev/sda1 /mnt/boot
  ```

  This is on a separate drive because I dual-boot Windows, which wants its own
  EFI partition on its own drive.

After making the mounts above, you can `arch-chroot` into the system with:

```bash
# -S flag is important for bootctl to work
arch-chroot -S /mnt
```

Then, you could hypothetically run `bootctl install` to install systemd-boot to
the EFI partition to "move-in" to the Windows EFI partition.

Afterwards, run `efibootmgr` to make sure the boot entries are correct. You may
need to change the boot order to make sure the systemd-boot entry is first --
this can be done with `efibootmgr -o XXXX,YYYY` where `XXXX` is the boot number
for systemd-boot and `YYYY` is the boot number for Windows Boot Manager.
