{ lib, ... }:
import ../../lib/btrfs-disk.nix {
  inherit lib;
  disk = "/dev/disk/by-id/REPLACE_WITH_BAYLEAF_DISK";
  encrypted = false;
  k3s = true;
  swapSize = "8G";
}
