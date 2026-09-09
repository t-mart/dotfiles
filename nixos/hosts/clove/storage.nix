{ ... }:
{
  fileSystems = {
    "/" = {
      device = "/dev/nvme0n1p2";
      fsType = "btrfs";
      options = [
        "subvol=@"
        "compress=zstd:3"
        "noatime"
      ];
    };
    "/home" = {
      device = "/dev/nvme0n1p2";
      fsType = "btrfs";
      options = [
        "subvol=@home"
        "compress=zstd:3"
        "noatime"
      ];
    };
    "/swap" = {
      device = "/dev/nvme0n1p2";
      fsType = "btrfs";
      options = [
        "subvol=@swap"
        "noatime"
      ];
    };
    "/var/log" = {
      device = "/dev/nvme0n1p2";
      fsType = "btrfs";
      options = [
        "subvol=@log"
        "compress=zstd:3"
        "noatime"
      ];
    };
    "/boot" = {
      device = "/dev/sda1";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];
}
