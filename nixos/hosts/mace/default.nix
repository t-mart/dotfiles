{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/router.nix
  ];

  networking.hostName = "mace";

  roles.router = {
    enable = true;
    wanInterface = "enp1s0";
    lanInterface = "enp2s0";
    lanAddress = "192.168.1.1/24";
    lanSubnet = "192.168.1.0/24";
  };

  system.stateVersion = "26.05";
}
