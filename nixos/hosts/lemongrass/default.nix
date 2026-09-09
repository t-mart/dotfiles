{ ... }:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/development.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/thinkpad-z13.nix
  ];

  networking.hostName = "lemongrass";
  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics.enable = true;
  system.stateVersion = "26.05";
}
