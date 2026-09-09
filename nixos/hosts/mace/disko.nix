{ lib, ... }:
import ../../lib/btrfs-disk.nix {
  inherit lib;
  disk = "/dev/disk/by-id/REPLACE_WITH_MACE_DISK";
  encrypted = false;
  swapSize = "4G";
}
