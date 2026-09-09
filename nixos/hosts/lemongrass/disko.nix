{ lib, ... }:
import ../../lib/btrfs-disk.nix {
  inherit lib;
  disk = "/dev/disk/by-id/REPLACE_WITH_LEMONGRASS_DISK";
  encrypted = true;
  swapSize = "16G";
}
