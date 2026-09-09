{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/development.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/printer.nix
  ];

  networking.hostName = "clove";
  home-manager.users.tim.imports = [ ../../modules/home/kubernetes.nix ];
  system.stateVersion = "26.05";
}
