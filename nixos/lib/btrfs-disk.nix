{
  lib,
  disk,
  encrypted ? false,
  k3s ? false,
  swapSize,
}:
let
  mountOptions = [
    "compress=zstd:3"
    "noatime"
  ];
  btrfs = {
    type = "btrfs";
    extraArgs = [ "-f" ];
    subvolumes = {
      "@root" = {
        mountpoint = "/";
        inherit mountOptions;
      };
      "@home" = {
        mountpoint = "/home";
        inherit mountOptions;
      };
      "@nix" = {
        mountpoint = "/nix";
        inherit mountOptions;
      };
      "@log" = {
        mountpoint = "/var/log";
        inherit mountOptions;
      };
      "@swap" = {
        mountpoint = "/swap";
        swap.swapfile.size = swapSize;
      };
    }
    // lib.optionalAttrs k3s {
      "@k3s" = {
        mountpoint = "/var/lib/rancher/k3s";
        inherit mountOptions;
      };
    };
  };
in
{
  disko.devices.disk.main = {
    type = "disk";
    device = disk;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        system = {
          size = "100%";
          content = if encrypted then {
            type = "luks";
            name = "crypted";
            settings.allowDiscards = true;
            content = btrfs;
          } else btrfs;
        };
      };
    };
  };
}
